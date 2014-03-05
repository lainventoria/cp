# encoding: utf-8
FactoryGirl.define do
  factory :retencion do
    monto { Money.new(rand(100)) }

    factura
  end
end
