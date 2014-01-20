require 'test_helper'

class CajaTest < ActiveSupport::TestCase
  test 'es válida' do
    assert (c = build(:caja)).valid?, c.errors.messages
  end

  test 'totaliza en pesos por default' do
    caja = create(:caja)
    2.times { create :movimiento, caja: caja, monto: Money.new(1000) }

    assert_equal Money.new(2000), caja.total
  end

  test 'totaliza por moneda' do
    caja = create(:caja)
    2.times { create :movimiento, caja: caja, monto: Money.new(1000) }
    2.times { create :movimiento, caja: caja, monto: Money.new(500, 'USD') }

    assert_equal Money.new(2000), caja.total
    assert_equal Money.new(1000, 'USD'), caja.total('USD')
  end

  test 'todos los totales' do
    caja = create(:caja)
    2.times { create :movimiento, caja: caja, monto: Money.new(1000) }
    2.times { create :movimiento, caja: caja, monto: Money.new(500, 'USD') }
    create :movimiento, caja: caja, monto: Money.new(500, 'EUR')

    assert_equal ({ 'ARS' => Money.new(2000),
                    'USD' => Money.new(1000, 'USD'),
                    'EUR' => Money.new(500, 'EUR') }), caja.totales
  end

  test 'caja en cero devuelve money' do
    caja = create(:caja)

    assert caja.movimientos.empty?

    assert_equal Money.new(0), caja.total
    assert_equal ({ 'ARS' => Money.new(0) }), caja.totales
  end

  test 'cambia moneda manteniendo el historial en forma de movimientos' do
    caja = create(:caja)
    create :movimiento, caja: caja, monto: Money.new(500, 'EUR')

    assert_difference 'Movimiento.count', 2 do
      @salida = caja.cambiar(Money.new(200, 'EUR'), 'ARS', 1.5)
    end

    assert_equal Money.new(300), @salida

    # Historial de movimientos
    assert caja.movimientos.collect(&:monto).include?(Money.new(500, 'EUR'))
    assert caja.movimientos.collect(&:monto).include?(Money.new(-200, 'EUR'))
    assert caja.movimientos.collect(&:monto).include?(Money.new(300))
  end

  test 'no cambia moneda si no hay suficiente' do
    caja = create(:caja)
    create :movimiento, caja: caja, monto: Money.new(100, 'EUR')

    assert_no_difference 'Movimiento.count' do
      @salida = caja.cambiar(Money.new(200, 'EUR'), 'ARS', 1.5)
    end

    assert_equal Money.new(0), @salida
  end
end
