# encoding: utf-8
require 'test_helper'

class TransferenciaTest < ActiveSupport::TestCase
  setup do
    @transferencia = Transferencia.new(caja: create(:cuenta,
      :con_fondos), monto: Money.new(100))
  end

  test 'es válida' do
    assert @transferencia.valid?, @transferencia.errors.messages.inspect
  end

  test 'es un medio de pago' do
    assert_kind_of CausaNoTrackeable, @transferencia
    assert_nothing_raised { @transferencia.usar_para_pagar build(:recibo) }
  end

  test 'sabe construirse' do
    assert_nothing_raised { Transferencia.construir({ algo: 'bonito'}) }
  end

  test 'devuelve un movimiento completo' do
    recibo = create(:recibo, situacion: 'pago')

    resultado = @transferencia.usar_para_pagar recibo

    assert_instance_of Movimiento, resultado
    assert_equal @transferencia.caja, resultado.caja
    assert_equal Money.new(-100), resultado.monto
    assert_equal 'Transferencia', resultado.causa_type
    assert_equal 1, resultado.causa_id
  end
end
