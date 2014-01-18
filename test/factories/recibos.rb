# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recibo do
    fecha "2014-01-17 21:25:25"
    importe { Money.new rand(1000) }
    emitido_o_recibido "emitido"

    factura
  end
end
