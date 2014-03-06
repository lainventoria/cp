# encoding: utf-8
class Movimiento < ActiveRecord::Base
  belongs_to :caja
  belongs_to :recibo, inverse_of: :movimientos

  monetize :monto_centavos, with_model_currency: :monto_moneda

  validates_presence_of :caja, :recibo, :monto
end
