class Factura < ActiveRecord::Base
  # Las facturas se pueden cancelar con muchos recibos
  has_many :recibos, inverse_of: :factura

  # Las situaciones posibles en que se genera una factura
  SITUACIONES = %w(cobro pago)
  # Sólo aceptamos esas :3
  validates_inclusion_of :situacion, in: SITUACIONES
  validates_numericality_of :saldo, greater_than_or_equal_to: 0

  monetize :importe_total_centavos
  monetize :saldo_centavos

  # Cuando se crea una Factura, el saldo es igual al importe_total
  before_create do |f| f.saldo = f.importe_total end

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
    saldo == Money.new(0)
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

  # Recalcula el saldo
  #
  # Cuánto se adeuda de esta factura en base a todos los recibos
  # NOTA esto asume que los recibos se hacen en la misma moneda de la
  # factura (y no que se está pagando una parte en una y otra en otra)
  # 
  # Antes de guardar un recibo se tiene que hacer la conversión a la
  # moneda de la factura
  def calcular_saldo
    self.saldo = importe_total - Money.new(recibos.sum(:importe_centavos), importe_total_moneda)
  end

	def nombre_y_numero
		"[#{numero}] #{nombre}"
	end

	def to_s
		nombre_y_numero
	end
end
