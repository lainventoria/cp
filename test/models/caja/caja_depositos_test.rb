# encoding: utf-8
require 'test_helper'

class CajaDepositosTest < ActiveSupport::TestCase
  setup do
    # Caja sin movimientos para la mayoría de los tests
    @caja = create :caja
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

  test 'depositar lanza excepciones opcionalmente' do
    # fingimos una falla en movimientos.build
    no_movimientos = MiniTest::Mock.new.expect :build, false, [Hash]

    @caja.stub :movimientos, no_movimientos do
      assert_raise ActiveRecord::Rollback do
        @caja.depositar(Money.new(100), true)
      end
    end
  end

  test 'hace un depósito respaldado con recibo interno' do
    create :movimiento, caja: @caja, monto: Money.new(1000)

    respaldo = @caja.depositar! Money.new(500)

    assert_instance_of Recibo, respaldo
    assert respaldo.interno?
    assert_equal Money.new(1500), @caja.total
    assert @caja.movimientos.collect(&:monto).include?(Money.new(500))
    assert respaldo.movimientos.collect(&:monto).include?(Money.new(500))
  end
end
