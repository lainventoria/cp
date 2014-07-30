# encoding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :movimiento do
    monto { Money.new(rand(100)) }

    caja
    recibo { Recibo.create situacion: 'interno' }
    causa { Efectivo.new }
  end
end
