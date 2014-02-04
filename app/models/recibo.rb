class Recibo < ActiveRecord::Base
  # Las facturas se cancelan con uno o más recibos
  belongs_to :factura, inverse_of: :recibos
  # Por eso cada recibo tiene que estar asociado a una factura
  validates_presence_of :factura
  validate :validate_cancelacion, :validate_saldo

  # Todas las situaciones en que se generan recibos
  SITUACIONES = %w(cobro pago)
  validates_inclusion_of :situacion, in: SITUACIONES

  monetize :importe_centavos

  # Es un recibo de pago?
  def pago?
    situacion == 'pago'
  end

  # Es un recibo de cobro?
  def cobro?
    situacion == 'cobro'
  end

  # Eso mismo
  def validate_cancelacion
    errors[:base] << "La factura ya fue cancelada" if factura.cancelada?
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
end
