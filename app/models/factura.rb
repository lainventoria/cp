# encoding: utf-8
class Factura < ActiveRecord::Base
  include ApplicationHelper

  # Las facturas pertenecen a un tercero
  belongs_to :tercero, inverse_of: :facturas
  belongs_to :obra, inverse_of: :facturas

  # Las facturas se pueden cancelar con muchos recibos
  has_many :recibos, inverse_of: :factura

  # Las situaciones posibles en que se genera una factura
  SITUACIONES = %w(cobro pago)
  # Sólo aceptamos esas :3
  validates_inclusion_of :situacion, in: SITUACIONES
  validates_numericality_of :importe_neto, greater_than_or_equal_to: 0
  validates_numericality_of :importe_total, greater_than_or_equal_to: 0
  validates_numericality_of :saldo, greater_than_or_equal_to: 0

  monetize :importe_neto_centavos
  monetize :importe_total_centavos
  monetize :saldo_centavos
  monetize :iva_centavos

  # Mantener actualizados los valores calculados cada vez que se hace
  # una modificación
  before_create :calcular_importe_total, :calcular_saldo
  before_update :calcular_importe_total, :calcular_saldo

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

  # Recalcula el saldo
  #
  # Cuánto se adeuda de esta factura en base a todos los recibos
  # NOTA esto asume que los recibos se hacen en la misma moneda de la
  # factura (y no que se está pagando una parte en una y otra en otra)
  # 
  # Antes de guardar un recibo se tiene que hacer la conversión a la
  # moneda de la factura
  def calcular_saldo
    # Cuando se crea una Factura, el saldo es igual al importe_total
    if self.new_record?
      self.saldo = importe_total
    else
      self.saldo = importe_total - Money.new(recibos.sum(:importe_centavos), importe_total_moneda)
    end
  end

  # El importe total o bruto es el neto con el IVA incluido
  def calcular_importe_total
    self.importe_total = self.importe_neto + self.iva
  end

end
