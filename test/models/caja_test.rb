# encoding: utf-8
require 'test_helper'

class CajaTest < ActiveSupport::TestCase
  setup do
    # Caja sin movimientos para la mayoría de los tests
    @caja = create :caja
  end

  test 'es válida' do
    assert (c = build(:caja)).valid?, c.errors.messages
  end

  test 'totaliza en pesos por default' do
    2.times { create :movimiento, caja: @caja, monto: Money.new(1000) }

    assert_equal Money.new(2000), @caja.total
  end

  test 'totaliza por moneda' do
    2.times { create :movimiento, caja: @caja, monto: Money.new(1000) }
    2.times { create :movimiento, caja: @caja, monto: Money.new(500, 'USD') }

    assert_equal Money.new(2000), @caja.total
    assert_equal Money.new(1000, 'USD'), @caja.total('USD')
  end

  test 'todos los totales' do
    2.times { create :movimiento, caja: @caja, monto: Money.new(1000) }
    2.times { create :movimiento, caja: @caja, monto: Money.new(500, 'USD') }
    create :movimiento, caja: @caja, monto: Money.new(500, 'EUR')

    assert_equal ({ 'ARS' => Money.new(2000),
                    'USD' => Money.new(1000, 'USD'),
                    'EUR' => Money.new(500, 'EUR') }), @caja.totales
  end

  test 'caja en cero devuelve money' do
    assert @caja.movimientos.empty?
    assert_equal Money.new(0), @caja.total
    assert_equal ({ 'ARS' => Money.new(0) }), @caja.totales
  end

  test 'extrae si alcanza' do
    create :movimiento, caja: @caja, monto: Money.new(2000)
    assert_equal 1, @caja.movimientos.count

    assert @caja.movimientos.where(recibo_id: @caja.extraer(Money.new(1000))).any?
    assert_equal 2, @caja.movimientos.count

    assert_nil @caja.extraer(Money.new(1001))
    assert_equal 2, @caja.movimientos.count
  end

  test 'extrae en cualquier moneda si alcanza' do
    create :movimiento, caja: @caja, monto: Money.new(2000, 'USD')

    assert @caja.movimientos.where(recibo_id: @caja.extraer(Money.new(1000, 'USD'))).any?
    assert_equal 2, @caja.movimientos.count

    assert_nil @caja.extraer(Money.new(500))
    assert_equal 2, @caja.movimientos.count
  end

  test 'deposita' do
    assert @caja.movimientos.where(recibo_id: @caja.depositar(Money.new(100))).any?
    assert @caja.movimientos.where(recibo_id: @caja.depositar(Money.new(100))).any?
    assert_equal 2, @caja.movimientos.count
    assert_equal Money.new(200), @caja.total
  end

  test 'deposita en cualquier moneda' do
    assert @caja.movimientos.where(recibo_id: @caja.depositar(Money.new(100, 'USD'))).any?
    assert_equal 1, @caja.movimientos.count
    assert_equal Money.new(100, 'USD'), @caja.total('USD')
  end

  test 'cambia moneda manteniendo el historial en forma de movimientos' do
    create :movimiento, caja: @caja, monto: Money.new(500, 'EUR')

    assert_difference 'Movimiento.count', 2 do
      @salida = @caja.cambiar(Money.new(200, 'EUR'), 'ARS', 1.5)
    end

    assert @caja.movimientos.where(recibo_id: @salida).any?

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
    # fingimos una falla en movimientos.create
    no_movimientos = MiniTest::Mock.new.expect :create, false, [Hash]

    @caja.stub :movimientos, no_movimientos do
      assert_raise ActiveRecord::Rollback do
        @caja.depositar(Money.new(100), true)
      end
    end
  end

  test 'no cambia moneda si no hay suficiente' do
    create :movimiento, caja: @caja, monto: Money.new(100, 'EUR')

    assert_no_difference 'Movimiento.count' do
      @salida = @caja.cambiar(Money.new(200, 'EUR'), 'ARS', 1.5)
    end

    assert_equal Money.new(0), @salida
  end

  test 'unifica los tipos prefiriendo el existente' do
    tipo_existente = 'Cajón sarasa'
    create(:caja, tipo: tipo_existente)

    assert_equal tipo_existente, create(:caja, tipo: ' Cajón    sarasa ').tipo
    assert_equal tipo_existente, create(:caja, tipo: 'Cajon sarasa').tipo
    assert_equal tipo_existente, create(:caja, tipo: 'cajón sarasa').tipo
  end

  test 'transferir dineros de una caja a otra' do
    caja1 = create :caja
    caja2 = create :caja
    dineros = Money.new(rand(1000))

    assert caja1.depositar dineros, caja1.errors.messages
    assert_equal dineros, caja1.total

    assert (recibo = caja1.transferir(dineros, caja2))
    assert_equal 2, recibo.movimientos.count
    assert_equal dineros, caja2.total
    assert_equal 0, caja1.total
  end
end
