# encoding: utf-8
FactoryGirl.define do
  factory :unidad_funcional do
    obra

    # un cocherito leré
    tipo UnidadFuncional::TIPOS.sample
    precio_venta { Money.new (10000000 + rand(100)*1000) }
    descripcion '1B'
  end
end
