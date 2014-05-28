# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tercero do
    nombre "Juan Salvo"
    cuit "20-31278322-4"
    relacion 'ambos'

    factory :proveedor do
      relacion 'proveedor'
    end

    factory :cliente do
      relacion 'cliente'
    end
  end
end
