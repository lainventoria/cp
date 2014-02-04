# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :factura do
    tipo "MyString"
    numero "MyString"
    situacion "pago"
    nombre "MyText"
    domicilio "MyText"
    cuit "MyText"
    iva 1.5
    descripcion "MyText"
    importe_total { Money.new rand(1000) }
    fecha "2014-01-17 20:21:17"
    fecha_pago "2014-01-17 20:21:17"
  end
end
