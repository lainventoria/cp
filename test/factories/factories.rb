# encoding: utf-8
FactoryGirl.define do
  sequence :cadena_unica, 'a'

  # Rotar entre CUITs que sabemos válidos. Podemos definir pocos porque sólo se
  # llama cuando el autogenerado falla
  sequence :cuit_default, 0 do |n|
    cuits = %w{20-31278322-4 20-12319302-5 20-10309499-3}
    cuits[n % cuits.size]
  end

  sequence :email do |n|
    "mail-numero-#{n}@falso.com"
  end
end
