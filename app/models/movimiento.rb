class Movimiento < ActiveRecord::Base
  belongs_to :caja

  monetize :monto_centavos, with_model_currency: :monto_moneda

  validates_presence_of :caja, :monto
end
