# encoding: utf-8
require 'test_helper'

class CajaMovimientosTest < ActiveSupport::TestCase
  setup do
    # Caja sin movimientos para la mayoría de los tests
    @caja = create :caja
  end

  test 'cambia moneda manteniendo el historial en forma de movimientos' do
    create :movimiento, caja: @caja, monto: Money.new(500, 'EUR')

    assert_difference 'Movimiento.count', 2 do
      @recibo_interno = @caja.cambiar(Money.new(200, 'EUR'), Money.new(300))
    end

    assert_equal 2, @caja.movimientos.where(recibo_id: @recibo_interno).count
    assert_equal 2, @recibo_interno.movimientos.count

    # Historial de movimientos
    assert @caja.movimientos.collect(&:monto).include?(Money.new(500, 'EUR'))
    assert @caja.movimientos.collect(&:monto).include?(Money.new(-200, 'EUR'))
    assert @caja.movimientos.collect(&:monto).include?(Money.new(300))

    @recibo_interno.movimientos.each do |m|
      assert_equal 'Operacion', m.causa_type
    end
  end

  test 'no cambia moneda si no hay suficiente' do
    create :movimiento, caja: @caja, monto: Money.new(100, 'EUR')

    assert_no_difference 'Movimiento.count' do
      @recibo_interno = @caja.cambiar(Money.new(200, 'EUR'), Money.new(300))
    end

    assert_nil @recibo_interno
  end

  test 'transferir dineros de una caja a otra' do
    origen = create :caja, :con_fondos
    destino = create :caja

    dineros = origen.total

    recibo = origen.transferir(dineros, destino)

    assert_instance_of Recibo, recibo
    assert_equal 2, recibo.movimientos.count
    assert_equal dineros, destino.total
    assert_equal 0, origen.total
    recibo.movimientos.each do |m|
      assert_equal 'Operacion', m.causa_type
    end
  end
end
