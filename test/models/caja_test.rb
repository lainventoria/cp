# encoding: utf-8
require 'test_helper'

class CajaTest < ActiveSupport::TestCase
  setup do
    # Caja sin movimientos para la mayoría de los tests
    @caja = create :caja
  end

  test 'es válida' do
    [ :build, :build_stubbed, :create].each do |metodo|
      assert_valid_factory metodo, :caja
      assert_valid_factory metodo, :chequera
      assert_valid_factory metodo, :banco
    end
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

  test 'unifica los tipos prefiriendo el existente' do
    tipo_existente = 'Cajón sarasa'
    create(:caja, tipo: tipo_existente)

    assert_equal tipo_existente, create(:caja, tipo: ' Cajón    sarasa ').tipo
    assert_equal tipo_existente, create(:caja, tipo: 'Cajon sarasa').tipo
    assert_equal tipo_existente, create(:caja, tipo: 'cajón sarasa').tipo
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

  test 'no permite tipos iguales en una misma obra y con el mismo numero' do
    caja1 = create :caja, tipo: 'Personal', obra_id: '1234', numero: ''

    # no permite cajas con mismo tipo
    assert_raise ActiveRecord::RecordInvalid do
      create :caja, tipo: 'Personal', obra_id: '1234', numero: ''
    end

    # a menos que tengan numeros diferentes
    assert create :caja, tipo: 'Personal', obra_id: '1234', numero:'1'
  end
end
