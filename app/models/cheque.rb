# encoding: utf-8
# Los cheques son promesas de cobro o pago, es decir que son movimientos
# futuros
# Solo se pueden depositar cuando están vencidos 
# Solo cuando se depositan generan un movimiento (positivo o negativo)
# en el recibo al que pertenecen
class Cheque < ActiveRecord::Base
  belongs_to :caja
  belongs_to :recibo, inverse_of: :cheques
  # aca van recibos internos!
  belongs_to :destino, class_name: 'Recibo', inverse_of: :cheques

  SITUACIONES = %w(propio terceros)
  validates_inclusion_of :situacion, in: SITUACIONES

  ESTADOS = %w(chequera depositado cobrado rechazado pagado)
  validates_inclusion_of :estado, in: ESTADOS

  # campos requeridos
  validates_presence_of :fecha_emision, :fecha_vencimiento, :monto,
                        :beneficiario
  # Todos los cheques tienen una caja, los de terceros una chequera, los
  # propios un banco
  validates_presence_of :caja_id

  # todos los cheques tiene un recibo
  validates_presence_of :recibo_id
  # solo tiene un destino luego de depositado
  # TODO validar que el destino no desaparezca cuando se cobra el cheque
  validates_presence_of :destino_id, if: :depositado?

  monetize :monto_centavos

  # Trae todos los cheques vencidos, si se le pasa una fecha trae los
  # vencidos a ese momento
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

  # para poder cobrar un cheque de terceros, antes se deposita en una
  # caja y se espera que el banco lo verifique.  equivale a una
  # transferencia de una caja a otra pero en dos pasos (o confirmación
  # manual).
  def depositar(caja_destino)
    # solo los cheques de terceros se depositan
    return nil unless self.terceros?
    # no se pueden depositar cheques en chequeras
    return nil if caja_destino.chequera?

    # El cheque se saca de una caja y se deposita en otra, como todavía
    # no lo cobramos, se registra como una salida 
    Cheque.transaction do
      self.destino = self.caja.extraer(self.monto)
      self.caja = caja_destino
      self.estado = 'depositado'
    end

    self.destino
  end

  # cuando se cobra un cheque depositado, se hace una transferencia de
  # la chequera a la caja destino
  def cobrar
    # solo los cheques depositados se pueden cobrar
    return nil unless self.depositado?

    Cheque.transaction do
      # terminar de transferir el monto del cheque de la chequera a la
      # caja destino
      self.caja.depositar(self.monto, true, self.destino)
      # marcar el cheque como cobrado
      self.estado = 'cobrado'
    end

    # devolver el recibo
    self.destino
  end

  # Los cheques propios generan movimientos de salida (negativos) cuando
  # se pagan
  def pagar
    # Solo los cheques propios se pueden pagar
    return nil unless self.propio?
    # Los cheques pagados no se pueden pagar dos veces!
    return nil if self.pagado?

    # Usamos las operaciones de caja
    Cheque.transaction do
      self.caja.extraer(self.monto, true, self.recibo)
      self.estado = 'pagado'
    end

    self.caja.movimientos.last
  end
end
