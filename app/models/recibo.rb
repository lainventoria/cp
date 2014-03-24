# encoding: utf-8
class Recibo < ActiveRecord::Base
  # Las facturas se cancelan con uno o más recibos
  belongs_to :factura, inverse_of: :recibos
  # los cheques son movimientos futuros
  has_many :cheques, inverse_of: :recibo
  # Los recibos disparan movimientos
  has_many :movimientos, inverse_of: :recibo
  # Por eso cada recibo tiene que estar asociado a una factura
  # a menos que sea un recibo interno (burocracia!)
  validates_presence_of :factura, unless: :interno?
  validate :validate_saldo, unless: :interno?

  before_save :actualizar_situacion, unless: :interno?

  # Todas las situaciones en que se generan recibos
  SITUACIONES = %w(cobro pago interno)
  validates_inclusion_of :situacion, in: SITUACIONES

  monetize :importe_centavos

  # Es un recibo de pago?
  def pago?
    self.situacion == 'pago'
  end

  # Es un recibo de cobro?
  def cobro?
    self.situacion == 'cobro'
  end

  def interno?
    situacion == 'interno'
  end

  def actualizar_situacion
    self.situacion = self.factura.situacion
  end

  # Si el recibo es nuevo, se resta del saldo de la factura, sino ya
  # estaba restado
  def validate_saldo
    if self.new_record?
      s = self.factura.saldo - self.importe
      errors[:base] << "El recibo no puede superar el saldo de la factura #{s}" if s < 0
    end
  end

end
