# encoding: utf-8
# Representa una clase de pago con una única instancia en el sistema, a la cual
# no nos interesa seguirle el rastro (e.g. efectivo).
class PagoNoTrackeable
  include ActiveModel::Naming
  include ActiveModel::Validations

  # Datos necesarios para generar los movimientos
  attr_accessor :monto, :caja, :caja_id, :monto_aceptado

  # Crea una asociación falsa. Por ejemplo
  #
  #   has_many :movimientos, as: :causa
  #
  # en la clase Efectivo define:
  #
  #   def movimientos
  #     Movimiento.where(causa_type: 'Efectivo', causa_id: id)
  #   end
  def self.has_many(cosos, opciones)
    modelo = cosos.to_s.classify.constantize
    poliforma = opciones[:as]

    define_method cosos do
      modelo.where(
        "#{poliforma}_type" => self.class.name,
        "#{poliforma}_id" => id
      )
    end
  end

  def self.construir(params)
    datos = params.extract! :monto_moneda, :monto, :caja_id, :caja,
      :monto_aceptado, :monto_aceptado_moneda
    new datos
  end

  def initialize(opciones = {})
    @caja = if opciones[:caja_id]
      Caja.find(opciones[:caja_id])
    else
      opciones[:caja]
    end

    # TODO quitar opciones de carga!
    @monto = parsear_monto  opciones[:monto],
                            opciones[:monto_moneda]
    @monto_aceptado = parsear_monto opciones[:monto_aceptado],
                                    opciones[:monto_aceptado_moneda]
  end

  # Los siguientes métodos son necesarios para que rails genere la asociación
  # desde el `belongs_to` del otro modelo

  # Usamos siempre el mismo id
  def id
    1
  end

  def [](key)
    self.send(key)
  end

  def destroyed?
    false
  end

  def new_record?
    false
  end

  def self.primary_key
    'id'
  end

  def self.base_class
    self
  end

  def self.column_names
    []
  end

  private

    def parsear_monto(monto, moneda = nil)
      if monto.class == Money
        monto
      else
        Monetize.parse monto.to_s + moneda.to_s
      end
    end
end
