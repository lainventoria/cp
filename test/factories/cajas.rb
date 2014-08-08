# encoding: utf-8
FactoryGirl.define do
  factory :caja do
    obra

    tipo 'De obra'
    situacion 'efectivo'

    # Para crear una caja que venga con 1k
    #
    #   create :caja, :con_fondos
    trait :con_fondos do
      ignore { monto 1000 }

      after(:create) do |caja, fabrica|
        create_list :movimiento, 1, monto: fabrica.monto, caja: caja
      end
    end

    factory :chequera do
      situacion 'chequera'
    end

    factory :cuenta do
      situacion 'banco'
      banco 'kickstarter'
    end
  end
end
