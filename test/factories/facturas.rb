# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :factura do
    tercero
    tipo "MyString"
    numero "MyString"
    situacion "pago"
    descripcion "MyText"
    importe_neto { Money.new rand(1000) }
    iva { Money.new(importe_neto * 0.21) }
    fecha "2014-01-17 20:21:17"
    fecha_pago "2014-01-17 20:21:17"
  end
end
