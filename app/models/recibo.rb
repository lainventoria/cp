# encoding: utf-8
class Recibo < ActiveRecord::Base
  # Las facturas se cancelan con uno o más recibos
  belongs_to :factura, inverse_of: :recibos
  has_one :obra, through: :factura
  has_one :tercero, through: :factura

  # Los recibos disparan movimientos
  has_many :movimientos, inverse_of: :recibo
  # Por eso cada recibo tiene que estar asociado a una factura
  # a menos que sea un recibo interno (burocracia!)
  validates_presence_of :factura, unless: :interno_o_temporal?
  validate :importe_no_supera_el_saldo, :meiosis_de_facturas,
           :todos_los_montos_son_monotonos, :siempre_es_hoy,
           unless: :interno_o_temporal?

  before_save :actualizar_situacion, unless: :interno_o_temporal?
  before_save :actualizar_importe_cache
  before_destroy :borrar_movimientos_asociados

  monetize :importe_cache_centavos, with_model_currency: :importe_cache_moneda

  # Todas las situaciones en que se generan recibos
  SITUACIONES = %w(cobro pago interno temporal)
  validates_inclusion_of :situacion, in: SITUACIONES
  after_initialize :garantizar_importe_cache_moneda_compatible

  # Crear un recibo interno para una transacción específica
  # TODO pasar a build?
  def self.interno_nuevo
    create(situacion: 'interno', fecha: Time.now)
  end

  def self.temporal_nuevo
    create(situacion: 'temporal', fecha: Time.now)
  end

  # Es un recibo de pago?
  def pago?
    situacion == 'pago'
  end

  # Es un recibo de cobro?
  def cobro?
    situacion == 'cobro'
  end

  def interno?
    situacion == 'interno'
  end

  def temporal?
    situacion == 'temporal'
  end

  def interno_o_temporal?
    interno? || temporal?
  end

  def actualizar_situacion
    self.situacion = factura.situacion
  end

  def pagar_o_cobrar_con(algo)
    if pago?
      pagar_con algo
    elsif cobro?
      cobrar_con algo
    end
  end

  def pagar_con(medio_de_pago)
    if medio_de_pago.present?
      if pago = medio_de_pago.usar_para_pagar(self)
        # TODO no haría falta si cada usar para pagar lo hace? o mejor, no paso
        # el recibo y ya
        if pago.errors.empty?
          movimientos.build caja: pago.caja, monto: pago.monto, causa: pago.causa
          save
        else
          errors.add :base, :medio_de_pago_invalido,
            causa: pago.causa_type,
            mensaje: pago.errors.messages.values.flatten.to_sentence
        end
      else
        # TODO Creo que ya no se llega acá
        false
      end
    else
      true # noop, como un save sin cambios
    end
  end

  def cobrar_con(medio_de_cobro)
    if medio_de_cobro.present?
      if cobro = medio_de_cobro.usar_para_cobrar(self)
        if cobro.errors.empty?
          movimientos.build caja: cobro.caja, monto: cobro.monto, causa: cobro.causa
          save
        else
          errors.add :base, :medio_de_cobro_invalido,
            causa: cobro.causa_type,
            mensaje: cobro.errors.messages.values.flatten.to_sentence
        end
      else
        # TODO Creo que ya no se llega acá
        false
      end
    else
      true # noop, como un save sin cambios
    end
  end

  # Calcula el importe del recibo en base a los movimientos existentes. Si el
  # recibo es de pago, los movimientos son de salida, asique los convertimos a
  # positivo
  def importe
    movimientos_en_moneda.collect(&:monto).sum.to_money(importe_moneda).abs
  end

  # El la moneda del importe de este recibo siempre va a ser la misma que su
  # factura
  def importe_moneda
    factura.try :importe_total_moneda
  end

  private

    def importe_no_supera_el_saldo
      if factura.present?
        errors.add :movimientos, :sobrepasan_el_saldo if importe_temporal > factura.saldo
      end
    end

    # comprueba que las cajas validas solo acepten facturas validas
    # el resto no importa
    def meiosis_de_facturas
      if factura.present? &&
         movimientos.any? { |m| m.caja.factura_valida? == factura.tipo_invalido? }

        errors.add :movimientos, :meiosis_de_facturas
      end
    end

    def todos_los_montos_son_monotonos
      if factura.present? && movimientos.any? { |m| m.monto_moneda != importe_moneda }
        errors.add :movimientos, :no_son_en_la_misma_moneda
      end
    end

    # recibo.importe devuelve la suma existente en la db (al ser llamado durante
    # las validaciones), que ya está restando del saldo, asique seleccionamos
    # sólo los movimientos nuevos
    def importe_temporal
      movimientos_en_moneda.select(&:new_record?).collect(&:monto).sum.to_money(importe_moneda).abs
    end

    # Sólo contabilizamos los que tengan la misma moneda que el recibo
    def movimientos_en_moneda
      movimientos.select { |m| m.monto_moneda == importe_moneda }
    end

    # No funciona el dependent porque algunas causas no son modelos reales :|
    def borrar_movimientos_asociados
      if temporal?
        # TODO Caso especial a reingenierizar
        movimientos.first.try :delete
      elsif movimientos.collect(&:causa).any?(&:trackeable?)
        false
      else
        movimientos.all?(&:destroy)
      end
    end

    # valida que si no pasamos fecha se ponga la actual
    def siempre_es_hoy
      self.fecha = Time.now if not fecha
    end

    def actualizar_importe_cache
      self.importe_cache = importe
    end

    def garantizar_importe_cache_moneda_compatible
      unless importe_cache.nonzero?
        self.importe_cache = Money.new(0, importe_moneda)
      end
    end
end
