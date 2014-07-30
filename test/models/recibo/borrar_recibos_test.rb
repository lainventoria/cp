# encoding: utf-8
require 'test_helper'

class BorrarRecibosTest < ActiveSupport::TestCase
  setup do
    # FIXME por qué hay que recargar para que tome los movimientos?
    @recibo = create(:recibo, :con_movimientos).reload
  end

  test 'borrar recibos borra sus movimientos' do
    assert Movimiento.all.count == 1
    assert @recibo.destroy
    assert Movimiento.all.count == 0
  end

  test 'borrar recibos borra sus movimientos a menos que tengan causa trackeable' do
    assert Movimiento.all.count == 1

    retencion = create :retencion, monto: Money.new(1000)
    @recibo.pagar_con retencion

    assert Movimiento.all.count == 2
    refute @recibo.destroy
    assert Movimiento.all.count == 2
  end
end
