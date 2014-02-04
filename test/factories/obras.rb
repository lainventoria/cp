# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :obra do
    nombre    { generate :cadena_unica }
    direccion { generate :cadena_unica }
  end
end
