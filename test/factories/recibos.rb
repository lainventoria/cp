#encoding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recibo do
    factura

    fecha "2014-01-17 21:25:25"
    situacion "pago"
  end
end
