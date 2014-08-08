# encoding: utf-8
FactoryGirl.define do
  factory :cheque do
    chequera
    cuenta

    banco 'adam smith & co'
    beneficiario 'pepe honguito'
    monto { Money.new(1 + rand(10)) }
    fecha_emision { Time.now }
    fecha_vencimiento { Time.now + rand(360000) }

    situacion 'propio'

    factory :cheque_de_terceros do
      situacion 'terceros'
      estado 'chequera'
      cuenta nil
    end
  end
end
