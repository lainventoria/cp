# encoding: utf-8
# Representa una clase de pago con una única instancia en el sistema, a la cual
# no nos interesa seguirle el rastro (e.g. efectivo).
class PagoNoTrackeable
  # Datos necesarios para generar los movimientos
  attr_accessor :monto, :caja

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

  def initialize(opciones = {})
    @caja = opciones[:caja]
    @monto = opciones[:monto]
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
end
