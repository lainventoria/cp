# encoding: utf-8
class Tercero < ActiveRecord::Base
  include ApplicationHelper

  # Cada tercero esta asociado a muchas facturas
  has_many :facturas, inverse_of: :tercero

  # Las relaciones posibles que se pueden tener con cada tercero
  RELACIONES = %w(cliente proveedor ambos)

  # Validaciones
  validates_inclusion_of :relacion, in: RELACIONES
  validates_presence_of :nombre, :cuit
  validate :validate_cuit

  # TODO este test complica las cosas durante el desarrollo inicial y usando
  # data dummy porque todos los cuits son iguales
  #  validates_uniqueness_of :cuit

  # Valida la validez del CUIT 
  def validate_cuit
    errors[:base] << "El CUIT no es válido" if not validar_cuit(self.cuit)
  end

  # Es un proveedor?
  def proveedor?
    relacion != "cliente"
  end

  # Es un cliente?
  def cliente?
    relacion != "proveedor"
  end
  
end
