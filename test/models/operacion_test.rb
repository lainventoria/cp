# encoding: utf-8
require 'test_helper'

class OperacionTest < ActiveSupport::TestCase
  setup do
    @operacion = Operacion.new(caja: create(:caja,
      :con_fondos), monto: Money.new(100))
  end

  test 'es válida' do
    assert @operacion.valid?, @operacion.errors.messages.inspect
  end

  test 'es una causa no trackeable' do
    assert_kind_of CausaNoTrackeable, @operacion
  end

  test 'sabe construirse' do
    assert_nothing_raised { Operacion.construir({ algo: 'bonito'}) }
  end

  test 'transfiere fondos entre cajas' do
    caja_destino = create :caja
    @operacion.caja_destino = caja_destino

    resultado = @operacion.transferir

    assert_instance_of Recibo, resultado
    assert resultado.movimientos.count == 2
    resultado.movimientos.each do |m|
      assert_instance_of Operacion, m.causa
    end
    assert @operacion.caja.movimientos.collect(&:monto).include?(Money.new(-100))
    assert caja_destino.reload.movimientos.collect(&:monto).include?(Money.new(100))
    assert_equal Money.new(100), caja_destino.total
  end

  test 'cambia de moneda en una caja' do
    @operacion.monto_aceptado = Money.new(500, 'EUR')

    resultado = @operacion.cambiar

    assert_instance_of Recibo, resultado
    assert resultado.movimientos.count == 2
    resultado.movimientos.each do |m|
      assert_instance_of Operacion, m.causa
    end
    assert @operacion.caja.movimientos.collect(&:monto).include?(Money.new(-100))
    assert @operacion.caja.movimientos.collect(&:monto).include?(Money.new(500, 'EUR'))
  end
end
