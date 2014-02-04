class Factura < ActiveRecord::Base
  # Las facturas se pueden cancelar con muchos recibos
  has_many :recibos, inverse_of: :factura

  # Las situaciones posibles en que se genera una factura
  SITUACIONES = %w(cobro pago)
  # Sólo aceptamos esas :3
  validates_inclusion_of :situacion, in: SITUACIONES

  monetize :importe_total_centavos

  # Chequea si la situación es pago
  def pago?
    situacion == 'pago'
  end

  # Chequea si la situación es cobro
  def cobro?
    situacion == 'cobro'
  end

  # La factura está cancelada cuando el saldo es 0
  def cancelada?
    saldo == 0
  end

  # Si el saldo es menor al importe_total es porque se pagó de más
  # Con las validaciones de Recibo no debería hacer falta
  def reintegro?
    saldo < importe_total
  end

  # Calcula el reintegro si se pagó de más
  # Con las validaciones de Recibo no debería hacer falta
  def reintegro
    saldo * -1 if reintegro?
  end

  # Cuánto se adeuda de esta factura en base a todos los recibos
  # TODO esto asume que los recibos se hacen en la misma moneda de la
  # factura (y no que se está pagando una parte en una y otra en otra)
  # Mandé un mail a la lista consultando qué hacer
  def saldo
    importe_total - Money.new(recibos.sum(:importe_centavos), importe_total_moneda)
  end

	def nombre_y_numero
		"[#{numero}] #{nombre}"
	end

	def to_s
		nombre_y_numero
	end
end
