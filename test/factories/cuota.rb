# encoding: utf-8
FactoryGirl.define do
  factory :cuota do
    contrato_de_venta

    monto_original { Money.new rand(1000) }
    vencimiento { Time.now.to_date + rand(30).days}
    descripcion 'cuota de prueba'
  end
end

