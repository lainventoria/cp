# encoding: utf-8
FactoryGirl.define do
  factory :tercero do
    nombre 'Juan Salvo'
    relacion 'ambos'

    # Generar cuits válidos, con default por si ninguno de los 10 zafa.
    sequence(:cuit, '00000000') do |n|
      (0..9).collect do |verificador|
        "10-#{n}-#{verificador}"
      end.select { |cuit| Tercero.validar_cuit(cuit) }.first || generate(:cuit_default)
    end

    factory :proveedor do
      relacion 'proveedor'
    end

    factory :cliente do
      relacion 'cliente'
    end

    trait :completo do
      contacto 'hablar con H.G.O'
      telefono '154123456789'
      celular '15912312234'
      email { generate :email }
      iva 0.21
      direccion 'El chalecito de Vicente López'
      notas 'usa traje'
    end
  end
end
