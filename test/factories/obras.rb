# encoding: utf-8
FactoryGirl.define do
  factory :obra do
    nombre    { generate :cadena_unica }
    direccion { generate :cadena_unica }
  end
end
