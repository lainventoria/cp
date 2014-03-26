# encoding: utf-8
require 'test_helper'

class CajaExtraccionesTest < ActiveSupport::TestCase
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

  test 'las chequeras pueden quedar en negativo' do
    chequera = create :chequera
    assert_equal Money.new(0), chequera.total

    movimiento = chequera.extraer Money.new(1000)

    assert_instance_of Movimiento, movimiento
    assert_equal Money.new(-1000), movimiento.monto
    assert chequera.movimientos.include? movimiento
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

  test 'hace una extracción respaldada con recibo interno' do
    create :movimiento, caja: @caja, monto: Money.new(1000)

    respaldo = @caja.extraer! Money.new(500)

    assert_instance_of Recibo, respaldo
    assert respaldo.interno?
    assert_equal Money.new(500), @caja.total
    assert @caja.movimientos.collect(&:monto).include?(Money.new(-500))
    assert respaldo.movimientos.collect(&:monto).include?(Money.new(-500))
  end

  test 'extraer lanza excepciones opcionalmente' do
    assert_raise ActiveRecord::Rollback do
      @caja.extraer(Money.new(100), true)
    end
  end
end
