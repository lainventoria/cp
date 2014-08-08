# encoding: utf-8
class Cuota < ActiveRecord::Base
  belongs_to :contrato_de_venta
  belongs_to :factura
  belongs_to :indice
  has_one :tercero, through: :contrato_de_venta
  has_one :obra, through: :contrato_de_venta

  monetize :monto_original_centavos, with_model_currency: :monto_original_moneda

  validates_numericality_of :monto_original_centavos, greater_than: 0
  validates_presence_of :vencimiento, :descripcion

  # mostrar todas las cuotas vencidas
  # que no sean el pago inicial porque es como la cuota 0
  scope :vencidas, lambda { |time = nil|
    time = Time.now if not time
    where.not(descripcion: 'Pago inicial').where('vencimiento < ?', time)
  }

  # cuotas con facturas emitidas
  scope :emitidas, lambda {
    where.not(factura: nil)
  }

  # cuotas sin factura emitida
  scope :pendientes, lambda {
    where(factura: nil)
  }

  def vencida?(time = nil)
    time = Time.now if not time

    vencimiento < time
  end

  # el monto actualizado es el monto original por el proporcional del
  # indice actual y el indice original
  def monto_actualizado(periodo = nil)
    monto_original * ( indice_actual(periodo).valor / contrato_de_venta.indice.valor )
  end

  # obtiene el indice actual según el indice del contrato y el
  # vencimiento o una fecha especificada
  #
  # si el indice no existe se crea uno temporal
  #
  def indice_actual(periodo = nil)
    # calcular el periodo si no lo especificamos
    periodo = contrato_de_venta.periodo_para(vencimiento) if periodo.nil?

    self.indice = Indice.por_fecha_y_denominacion(periodo, contrato_de_venta.indice.denominacion)
  end

  # pagar la cuota genera una factura de cobro que el tercero adeuda
  def generar_factura(periodo = nil)
    vencimiento_actual = self.vencimiento
    # si la cuota se paga antes de tiempo, el monto actualizado se
    # calcula al indice del mes actual en lugar del indice del mes de
    # vencimiento
    unless vencida?
      periodo = contrato_de_venta.periodo_para(Date.today)
      vencimiento_actual = Date.today
    end

    Factura.transaction do
      # FIXME faltan tipo y número
      self.factura = Factura.new(situacion: 'cobro',
        importe_neto: monto_actualizado(periodo),
        fecha: vencimiento_actual,
        fecha_pago: vencimiento_actual + 10.days,
        descripcion: descripcion,
        tercero: tercero,
        obra: obra)
      self.save
      self.factura
    end
  end
end
