# encoding: utf-8
class Tercero < ActiveRecord::Base
  # Cada tercero esta asociado a muchas facturas
  has_many :facturas, inverse_of: :tercero, dependent: :restrict_with_error
  has_many :contratos_de_venta

  # Las relaciones posibles que se pueden tener con cada tercero
  RELACIONES = %w(cliente proveedor ambos)

  # Validaciones
  validates_inclusion_of :relacion, in: RELACIONES
  validates_presence_of :nombre, :cuit
  validates_uniqueness_of :cuit
  validate :el_cuit_es_valido

  normalize_attribute :cuit do |valor|
    normalizar_cuit(valor)
  end

  # seguramente hay una forma más elegante de hacer esto...
  def self.validar_cuit(cuit)
    cuit_normalizado = normalizar_cuit(cuit)

    # parece que el cuit es siempre de 11 cifras
    return false unless cuit_normalizado.length == 11

    multiplicadores = [ 5, 4, 3, 2, 7, 6, 5, 4, 3, 2, 1 ]
    resultado = 0

    # multiplica cada elemento del cuit por uno de los multiplicadores
    (0..10).each do |i|
      resultado = resultado + cuit_normalizado[i].to_i * multiplicadores[i]
    end

    # el cuit es valido si el resto de dividir el resultado por 11 es 0
    (resultado % 11) == 0
  end

  # Fuerza string y remueve lo que no son números
  def self.normalizar_cuit(cuit)
    cuit.to_s.gsub(/[^0-9]/, '')
  end

  # Es un proveedor?
  def proveedor?
    relacion != 'cliente'
  end

  # Es un cliente?
  def cliente?
    relacion != 'proveedor'
  end

  def cuit_valido?
    Tercero.validar_cuit(cuit)
  end

  def volverse_cliente
    if proveedor?
      self.relacion = 'ambos'
    end
    relacion
  end

  private

    def el_cuit_es_valido
      errors.add(:cuit, :no_es_valido) unless cuit_valido?
    end
end
