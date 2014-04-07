# encoding: utf-8
# La Oficina Central es agente de retención de la AFIP. Retiene tanto Impuesto
# a las Ganancias como Cargas Sociales. Las retenciones las determina el
# contador, potencialmente cada factura tiene una retención asociada que sirve
# como medio de pago de la misma
class Retencion < ActiveRecord::Base
  include CausaDeMovimientos

  SITUACIONES = %w(ganancias cargas_sociales)
  # TODO estados (usada, pagada, emitida)
  # 'emitida' lo usaríamos cuando la retención ya se haya creado en el sistema,
  # pero aun no se haya sumado a un recibo. Cuando se sume a un recibo,
  # entonces las pasamos a 'usada'

  # La factura sobre la que se hace la retención
  belongs_to :factura
  has_one :obra, through: :factura
  has_one :tercero, through: :factura

  # Las retenciones se pagan desde una cuenta
  belongs_to :cuenta, ->{ where(situacion: 'banco') },
    class_name: 'Caja'

  # Todas las retenciones pertenecen a una especie de chequera, que es donde
  # se contabilizan los pagos. Técnicamente no es una chequera pero por ahora
  # es lo mismo
  belongs_to :chequera, ->{ where(situacion: 'chequera') },
    class_name: 'Caja'

  has_many :recibos, through: :movimientos

  # Sólo PDFs
  has_attached_file :documento

  validates_inclusion_of :situacion, in: SITUACIONES
  validates_presence_of :factura, :monto, :fecha_vencimiento, :chequera
  validates_attachment_presence :documento
  validates_attachment_content_type :documento, content_type: /\Aapplication\/pdf\Z/
  validates_uniqueness_of :situacion, scope: :factura_id

  validate :factura_es_un_pago, :tipo_de_chequera, :tipo_de_cuenta

  after_create :contabilizar_deuda

  monetize :monto_centavos, with_model_currency: :monto_moneda

  state_machine :estado, initial: :emitida do
    event :pagar do
      transition :emitida  => :pagada
      transition :aplicada => :pagada, unless: :se_pago?
    end

    event :aplicar do
      transition :emitida => :aplicada
      transition :pagada  => :aplicada, unless: :fue_usada_como_pago?
    end

    event :cerrar do
      transition :aplicada  => :cerrada, if: :se_pago?
      transition :pagada    => :cerrada, if: :fue_usada_como_pago?
    end

    after_transition to: [:aplicada, :pagada], do: :cerrar

    state :pagada do
      validates_presence_of :cuenta
    end
  end

  def self.construir(params)
    id_ret = params.extract! :retencion_id

    # TODO scopear a obra y cosas así
    if id_ret.present?
      find(id_ret[:retencion_id])
    end
  end

  # Es una causa de movimientos de la cuál nos interesa preservar información
  def trackeable?
    true
  end

  def ganancias?
    situacion == 'ganancias'
  end

  def cargas_sociales?
    situacion == 'cargas_sociales'
  end

  # Las retenciones extraen de su cuenta y saldan la chequera cuando
  # se le paga a la AFIP
  def pagar!
    Cheque.transaction do
      recibo = Recibo.interno_nuevo

      salida = cuenta.extraer(monto, true)
      salida.causa = self
      entrada = chequera.depositar(monto, true)
      entrada.causa = self

      recibo.movimientos << salida << entrada

      pagar
    end
  end

  # Usar esta retención como medio de pago. La asociamos como causa del movimiento
  # de extracción de la AFIP (deuda con ellos), y asociamos el recibo de pago
  # al movimiento.
  # TODO revisar, no haría falta en ningún `usar_para_pagar` pasar el recibo, excepto
  # para validaciones y cosas así, ya que este método se llama desde Recibo.
  def usar_para_pagar(este_recibo)
    Retencion.transaction do
      if movimiento = deuda_pendiente
        movimiento.causa = self
        movimiento.recibo = este_recibo
        aplicar and borrar_recibo_temporal
        movimiento
      else
        false
      end
    end
  end

  def descripcion
    "#{monto_moneda} #{monto} - #{situacion.humanize} (vence el #{I18n.l fecha_vencimiento.to_date})"
  end

  def fue_usada_como_pago?
    recibos.where(situacion: 'pago').any?
  end

  def se_pago?
    recibos.where(situacion: 'interno').any?
  end

  def deuda_pendiente
    recibos.where(situacion: 'temporal').first.movimientos.first
  end

  private

    def factura_es_un_pago
      errors.add :factura, :debe_ser_un_pago unless factura.pago?
    end

    def tipo_de_chequera
      errors.add(:chequera_id, :debe_ser_una_chequera) unless chequera.chequera?
    end

    def tipo_de_cuenta
      if cuenta.present?
        errors.add(:cuenta_id, :debe_ser_una_cuenta_de_banco) unless cuenta.banco?
      end
    end

    # Genera un recibo temporal para almacenar la deuda que representa esta
    # retención. Este recibo se reemplaza al usar la retención como pago
    def contabilizar_deuda
      Retencion.transaction do
        temporal = Recibo.temporal_nuevo
        if movimiento = chequera.extraer(monto, true)
          movimiento.causa = self
          temporal.movimientos << movimiento
          temporal.save
        end
      end
    end

    def borrar_recibo_temporal
      recibos.where(situacion: 'temporal').first.destroy
    end
end
