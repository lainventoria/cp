# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :factura do
    tipo "MyString"
    numero "MyString"
    emitida false
    recibida false
    nombre "MyText"
    domicilio "MyText"
    cuit "MyText"
    iva 1.5
    descripcion "MyText"
    importe_total ""
    fecha "2014-01-17 20:21:17"
    fecha_pago "2014-01-17 20:21:17"
  end
end
