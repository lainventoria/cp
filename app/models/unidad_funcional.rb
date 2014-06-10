# encoding: utf-8
class UnidadFuncional < ActiveRecord::Base
  belongs_to :obra
  belongs_to :contrato_de_venta
  has_one :tercero, through: :contrato_de_venta

  validates_presence_of :tipo, :obra_id, :precio_venta

  monetize :precio_venta_centavos, with_model_currency: :precio_venta_moneda
end
