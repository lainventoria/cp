class Recibo < ActiveRecord::Base
  # Las facturas se cancelan con uno o más recibos
  belongs_to :factura
  # Por eso cada recibo tiene que estar asociado a una factura
  validates_presence_of :factura

  # Validar los montos ingresados para que después no haya que hacer
  # reintegros
  validate do |recibo|
    # Si la factura ya fue cancelada no hace falta generar un recibo
    recibo.errors[:base] << "La factura ya fue cancelada" if recibo.factura.cancelada?

    # Si el saldo es menor al importe de este recibo, hay que hacer un
    # recibo más chico
    if recibo.factura.saldo < recibo.importe
      recibo.errors[:base] << "El monto ingresado es superior al saldo #{recibo.factura.saldo}"
    end
  end

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
end
