# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :movimiento do
    monto { Money.new(rand(100)) }

    caja
  end
end
