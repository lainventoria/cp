# encoding: utf-8
# Los cheques son promesas de cobro o pago, es decir que son movimientos
# futuros
# Solo se pueden depositar cuando están vencidos
# Solo cuando se depositan generan un movimiento (positivo o negativo)
# en el recibo al que pertenecen
class Cheque < ActiveRecord::Base
  include MedioDePago

  # Los cheques tienen una cuenta sólo si son propios o han sido depositados
  belongs_to :cuenta, ->{ where(situacion: 'banco') },
    class_name: 'Caja'
  belongs_to :chequera, ->{ where(situacion: 'chequera') },
    class_name: 'Caja'

  has_many :recibos, through: :movimientos do
    # TODO hay casos donde haya más de un recibo interno?
    def interno
      where(situacion: 'interno').first
    end
  end

  SITUACIONES = %w(propio terceros)
  validates_inclusion_of :situacion, in: SITUACIONES

  ESTADOS = %w(chequera depositado cobrado rechazado pagado pasamanos)
  validates_inclusion_of :estado, in: ESTADOS

  # campos requeridos
  validates_presence_of :fecha_emision, :fecha_vencimiento, :monto,
                        :beneficiario

  # Todos los cheques pertenecen a una chequera, si son de terceros es donde se
  # contabiliza el pago, si son propios es de donde se contabiliza la emisión
  # del cheque
  validates_presence_of :chequera
  validate :tipo_de_chequera, :tipo_de_cuenta

  monetize :monto_centavos, with_model_currency: :monto_moneda

  # Trae todos los cheques vencidos, si se le pasa una fecha trae los
  # vencidos a ese momento
  # TODO testear
  scope :vencidos, lambda { |time = nil|
    time = Time.now if not time
    where("fecha_vencimiento < ?", time)
  }

  # Trae todos los cheques depositados
  scope :depositados, lambda {
    where(estado: 'depositado')
  }

  def vencido?
    fecha_vencimiento < Time.now
  end

  def propio?
    situacion == 'propio'
  end

  def terceros?
    situacion == 'terceros'
  end

  def depositado?
    estado == 'depositado'
  end

  def pagado?
    estado == 'pagado'
  end

  def chequera?
    estado == 'chequera'
  end

  def pasamanos?
    estado == 'pasamanos'
  end

  # Para poder cobrar un cheque de terceros, antes se deposita en una
  # caja y se espera que el banco lo verifique. Equivale a una
  # transferencia de una caja a otra pero en dos pasos (o confirmación
  # manual).
  def depositar(cuenta_destino)
    # TODO validar
    # solo los cheques de terceros se depositan
    return nil unless terceros?
    # no se pueden depositar cheques en chequeras
    return nil if cuenta_destino.chequera?

    # El cheque se saca de una caja y se deposita en otra, como todavía
    # no lo cobramos, se registra como una salida
    Cheque.transaction do
      recibo = Recibo.interno_nuevo
      movimiento = chequera.extraer(monto, true)
      movimiento.causa = self
      recibo.movimientos << movimiento

      # FIXME update
      self.estado = 'depositado'
      self.cuenta = cuenta_destino
      save
    end

    self
  end

  # Cuando se cobra un cheque depositado, se termina una transferencia de
  # la chequera a la caja destino
  def cobrar
    # solo los cheques depositados se pueden cobrar
    return nil unless depositado?

    Cheque.transaction do
      # terminar de transferir el monto del cheque de la chequera a la
      # caja destino
      movimiento = cuenta.depositar(monto, true)
      movimiento.causa = self
      recibos.interno.movimientos << movimiento

      # marcar el cheque como cobrado
      self.estado = 'cobrado'
      save
    end

    self
  end

  # Los cheques extraen de su cuenta y saldan la chequera cuando
  # se pagan, sólo pueden ser cheques propios
  # TODO verificar esto ↑
  def pagar
    # Los cheques pagados no se pueden pagar dos veces!
    return nil if pagado?
    # solo los cheques de terceros que se pasaron de manos se pueden
    # pagar
    return nil if terceros?

    Cheque.transaction do
      self.estado = 'pagado'
      recibo = Recibo.interno_nuevo

      salida = cuenta.extraer(monto, true)
      salida.causa = self
      entrada = chequera.depositar(monto, true)
      entrada.causa = self

      recibo.movimientos << salida << entrada

      save
    end

    self
  end

  # Usar este cheque como medio de pago. Lo asociamos como causa del movimiento
  # de extracción de su caja, y asociamos el recibo de pago al movimiento.
  def usar_para_pagar(este_recibo)
    # TODO cambiar estos checks por errores
    # tienen que estar en la chequera
    return nil unless chequera?
    # y se asocian a recibos de pago
    return nil unless este_recibo.pago?

    Cheque.transaction do
      # TODO Qué estado ponerle a un cheque propio usado como pago?
      self.estado = 'pasamanos' if terceros?
      movimiento = chequera.extraer(monto)
      movimiento.causa = self
      este_recibo.movimientos << movimiento
      save
    end

    self
  end

  # TODO pasar un concern
  def usar_para_cobrar(este_recibo)
    if terceros?
      Cheque.transaction do
        movimiento = chequera.depositar(monto)
        movimiento.causa = self
        este_recibo.movimientos << movimiento
        save
      end
    else
      errors.add(:situacion, :debe_ser_de_terceros)
    end

    self
  end

  private

    def tipo_de_chequera
      errors.add(:chequera_id, :debe_ser_una_chequera) unless chequera.chequera?
    end

    def tipo_de_cuenta
      if cuenta.present?
        errors.add(:cuenta_id, :debe_ser_una_cuenta_de_banco) unless cuenta.banco?
      end
    end
end
