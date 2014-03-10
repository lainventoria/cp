# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tercero do
    nombre "MyString"
    cuit "20-31278322-4"
    contacto "MyString"
    telefono "MyString"
    celular "MyString"
    email "MyString"
    iva { rand(50) }
    relacion "ambos"
    direccion "MyString"
    notas "MyText"
  end
end
