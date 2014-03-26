# encoding: utf-8
require 'test_helper'

class CajaTest < ActiveSupport::TestCase
  setup do
    # Caja sin movimientos para la mayoría de los tests
    @caja = create :caja
  end

  test 'es válida' do
    [ :build, :build_stubbed, :create].each do |metodo|
      assert_valid_factory metodo, :caja
      assert_valid_factory metodo, :chequera
      assert_valid_factory metodo, :cuenta
    end
  end

  test 'unifica los tipos prefiriendo el existente' do
    tipo_existente = 'Cajón sarasa'
    create(:caja, tipo: tipo_existente)

    assert_equal tipo_existente, create(:caja, tipo: ' Cajón    sarasa ').tipo
    assert_equal tipo_existente, create(:caja, tipo: 'Cajon sarasa').tipo
    assert_equal tipo_existente, create(:caja, tipo: 'cajón sarasa').tipo
  end

  test 'no permite tipos iguales en una misma obra y con el mismo numero' do
    caja1 = create :caja, tipo: 'Personal', obra_id: '1234', numero: ''

    # no permite cajas con mismo tipo
    assert_raise ActiveRecord::RecordInvalid do
      create :caja, tipo: 'Personal', obra_id: '1234', numero: ''
    end

    # a menos que tengan numeros diferentes
    assert create :caja, tipo: 'Personal', obra_id: '1234', numero:'1'
  end

  test 'emite cheques propios' do
    cheque = @caja.emitir_cheque(
      attributes_for(:cheque, monto: Money.new(100))
    )

    assert_instance_of Cheque, cheque
    assert cheque.propio?
    assert_equal Money.new(100), cheque.monto
    assert_equal @caja.obra.chequera_propia, cheque.chequera
  end
end
