# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :factura do
    obra
    tercero
    tipo "A"
    numero "MyString"
    situacion "pago"
    descripcion "MyText"
    importe_neto { Money.new (1000 + rand(1000)) }
    iva { Money.new(importe_neto * 0.21) }
    fecha "2014-01-17 20:21:17"
    fecha_pago "2014-01-17 20:21:17"
  end
end
