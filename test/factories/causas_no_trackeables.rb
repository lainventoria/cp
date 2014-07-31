# encoding: utf-8
FactoryGirl.define do
  factory :causa_no_trackeable do
    association :caja, :con_fondos
    monto Money.new(1000)

    factory :efectivo, class: 'Efectivo' do
    end

    factory :transferencia, class: 'Transferencia' do
      caja { build(:cuenta) }
    end

    factory :operacion, class: 'Operacion' do
      caja_destino { build(:caja) }
    end
  end
end
