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
  validate :validate_cancelacion, :validate_saldo, unless: :interno?

  # Actualiza el saldo de la factura cuando guardamos un valor
  after_save :actualizar_saldo, unless: :interno?
  after_destroy :actualizar_saldo, unless: :interno?

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

  # Eso mismo
  def validate_cancelacion
    errors[:base] << "La factura ya fue cancelada" if self.factura.cancelada?
  end

  # Valida el saldo de la factura
  def validate_saldo
    # Si el registro es nuevo, para saber el saldo real antes de
    # insertar tenemos que restar el importe actual
    if self.new_record?
      saldo = factura.saldo - importe
    # Cuando ya está en la base directamente comprobamos el saldo
    else
      saldo = factura.saldo
    end

    errors[:base] << "El importe es mayor al saldo #{saldo}" if saldo < 0
  end

  def actualizar_saldo
    self.factura.calcular_saldo
    self.factura.save
  end

  def actualizar_situacion
    self.situacion = self.factura.situacion
  end

end
