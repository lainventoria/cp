# encoding: utf-8
require 'test_helper'

class EfectivoTest < ActiveSupport::TestCase
  setup do
    @efectivo =  Efectivo.new(caja: create(:caja,
      :con_fondos), monto: Money.new(100))
  end

  test 'es un medio de pago' do
    assert_kind_of PagoNoTrackeable, @efectivo
    assert_nothing_raised { @efectivo.usar_para_pagar build(:recibo) }
  end

  test 'devuelve un movimiento completo' do
    recibo = create(:recibo, importe: Money.new(1000), situacion: 'pago')

    resultado = @efectivo.usar_para_pagar recibo

    assert_instance_of Movimiento, resultado
    assert_equal @efectivo.caja, resultado.caja
    assert_equal Money.new(-100), resultado.monto
    assert_equal 'Efectivo', resultado.causa_type
    assert_equal 1, resultado.causa_id
  end
end