# encoding: utf-8
require 'test_helper'

class CajaMovimientosTest < ActiveSupport::TestCase
  setup do
    # Caja sin movimientos para la mayoría de los tests
    @caja = create :caja
  end

  test 'extrae si alcanza y devuelve el movimiento' do
    create :movimiento, caja: @caja, monto: Money.new(2000)
    assert_equal 1, @caja.movimientos.count

    movimiento = @caja.extraer Money.new(1000)

    assert_instance_of Movimiento, movimiento
    assert_equal Money.new(-1000), movimiento.monto
    assert_equal @caja, movimiento.caja
    assert @caja.movimientos.include? movimiento

    assert movimiento.update_attribute :recibo, Recibo.interno_nuevo
    assert_equal 2, @caja.movimientos.count
  end

  test 'no extrae si no alcanza' do
    create :movimiento, caja: @caja, monto: Money.new(1000)

    assert_no_difference '@caja.movimientos.count' do
      assert_nil @caja.extraer(Money.new(1001))
    end
  end

  test 'extrae en cualquier moneda si alcanza' do
    create :movimiento, caja: @caja, monto: Money.new(2000, 'USD')

    movimiento = @caja.extraer Money.new(1000, 'USD')

    assert_equal Money.new(-1000, 'USD'), movimiento.monto
    assert_equal @caja, movimiento.caja
    assert @caja.movimientos.include? movimiento
    assert movimiento.update_attribute :recibo, Recibo.interno_nuevo
    assert_equal 2, @caja.movimientos.count

    assert_nil @caja.extraer(Money.new(500))
  end

  test 'deposita' do
    movimiento = @caja.depositar(Money.new(100))
    assert_instance_of Movimiento, movimiento
    assert_equal Money.new(100), movimiento.monto
    assert @caja.movimientos.include? movimiento
    assert movimiento.update_attribute :recibo, Recibo.interno_nuevo
    assert_equal 1, @caja.movimientos.count
  end

  test 'deposita en cualquier moneda' do
    movimiento = @caja.depositar(Money.new(100, 'USD'))
    assert_instance_of Movimiento, movimiento
    assert_equal Money.new(100, 'USD'), movimiento.monto
    assert @caja.movimientos.include? movimiento
    assert movimiento.update_attribute :recibo, Recibo.interno_nuevo
    assert_equal 1, @caja.movimientos.count
  end

  test 'cambia moneda manteniendo el historial en forma de movimientos' do
    create :movimiento, caja: @caja, monto: Money.new(500, 'EUR')

    assert_difference 'Movimiento.count', 2 do
      @recibo_interno = @caja.cambiar(Money.new(200, 'EUR'), 'ARS', 1.5)
    end

    assert_equal 2, @caja.movimientos.where(recibo_id: @recibo_interno).count
    assert_equal 2, @recibo_interno.movimientos.count

    # Historial de movimientos
    assert @caja.movimientos.collect(&:monto).include?(Money.new(500, 'EUR'))
    assert @caja.movimientos.collect(&:monto).include?(Money.new(-200, 'EUR'))
    assert @caja.movimientos.collect(&:monto).include?(Money.new(300))
  end

  test 'extraer lanza excepciones opcionalmente' do
    assert_raise ActiveRecord::Rollback do
      @caja.extraer(Money.new(100), true)
    end
  end

  test 'depositar lanza excepciones opcionalmente' do
    # fingimos una falla en movimientos.build
    no_movimientos = MiniTest::Mock.new.expect :build, false, [Hash]

    @caja.stub :movimientos, no_movimientos do
      assert_raise ActiveRecord::Rollback do
        @caja.depositar(Money.new(100), true)
      end
    end
  end

  test 'no cambia moneda si no hay suficiente' do
    create :movimiento, caja: @caja, monto: Money.new(100, 'EUR')

    assert_no_difference 'Movimiento.count' do
      @recibo_interno = @caja.cambiar(Money.new(200, 'EUR'), 'ARS', 1.5)
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
  end
end
