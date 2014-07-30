# encoding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recibo do
    factura

    fecha "2014-01-17 21:25:25"
    situacion "pago"

    # Para crear un recibo con movimientos
    #
    #   create :recibo, :con_movimientos
    #   create :recibo, :con_movimientos, cantidad: 10
    trait :con_movimientos do
      ignore { cantidad 1 }

      after(:create) do |recibo, fabrica|
        create_list :movimiento, fabrica.cantidad, recibo: recibo
      end
    end
  end
end
