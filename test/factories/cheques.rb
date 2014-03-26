# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :cheque do
    chequera

    beneficiario "pepe honguito"
    monto { Money.new rand(10) }
    fecha_emision { Time.now }
    fecha_vencimiento { Time.now + rand(360000) }

    factory :cheque_de_terceros do
      situacion 'terceros'
      estado 'chequera'
    end
  end
end
