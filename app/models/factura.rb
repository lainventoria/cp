# encoding: utf-8
class Factura < ActiveRecord::Base
  include ApplicationHelper

  # Las facturas pertenecen a un tercero
  belongs_to :tercero, inverse_of: :facturas

  # Las facturas se pueden cancelar con muchos recibos
  has_many :recibos, inverse_of: :factura

  # Las situaciones posibles en que se genera una factura
  SITUACIONES = %w(cobro pago)
  # Sólo aceptamos esas :3
  validates_inclusion_of :situacion, in: SITUACIONES
  validates_numericality_of :importe_neto, greater_than_or_equal_to: 0
  validates_numericality_of :importe_total, greater_than_or_equal_to: 0

  validate :validate_saldo

  monetize :importe_neto_centavos
  monetize :importe_total_centavos
  monetize :iva_centavos

  # Mantener actualizados los valores calculados cada vez que se hace
  # una modificación
  before_validation :calcular_importe_total

  # Chequea si la situación es pago
  def pago?
    self.situacion == 'pago'
  end

  # Chequea si la situación es cobro
  def cobro?
    self.situacion == 'cobro'
  end

  # La factura está cancelada cuando el saldo es 0
  def cancelada?
    self.saldo == Money.new(0)
  end

  # Si el saldo es menor al importe_total es porque se pagó de más
  # Con las validaciones de Recibo no debería hacer falta
  def reintegro?
    self.saldo < self.importe_total
  end

  # Calcula el reintegro si se pagó de más
  # Con las validaciones de Recibo no debería hacer falta
  def reintegro
    self.saldo * -1 if reintegro?
  end

  # calcula el saldo
  #
  # Cuánto se adeuda de esta factura en base a todos los recibos
  # NOTA esto asume que los recibos se hacen en la misma moneda de la
  # factura (y no que se está pagando una parte en una y otra en otra)
  # 
  # Antes de guardar un recibo se tiene que hacer la conversión a la
  # moneda de la factura
  def saldo
    # Cuando se crea una Factura, el saldo es igual al importe_total
    if self.new_record?
      importe_total
    else
      importe_total - Money.new(self.recibos.sum(:importe_centavos), self.importe_total_moneda)
    end
  end

  # El importe total o bruto es el neto con el IVA incluido
  def calcular_importe_total
    self.importe_total = self.importe_neto + self.iva
  end

  # TODO esto en realidad tiene que calcular el saldo en base a los
  # recibos en memoria, no a los que ya están en la base de datos
  def validate_saldo
    errors[:base] << "El total sobrepasa el saldo de la factura" if self.saldo < 0
  end

end
