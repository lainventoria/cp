require 'test_helper'

class ChequeTest < ActiveSupport::TestCase
  test "es válido" do
    [ :build, :build_stubbed, :create].each do |metodo|
      assert_valid_factory metodo, :cheque
      assert_valid_factory metodo, :cheque_de_terceros
    end
  end

  test "el cheque está vencido" do
    cheque = create :cheque, fecha_vencimiento: Time.now - rand(360000)

    assert cheque.vencido?, "#{Time.now} > #{cheque.fecha_vencimiento}"
  end

  test "el cheque no está vencido" do
    cheque = create :cheque

    assert_not cheque.vencido?, "#{Time.now} > #{cheque.fecha_vencimiento}"
  end

  test "algunos cheques se vencen" do
    create :cheque # no vencido
    cheque_vencido = create :cheque, fecha_vencimiento: Time.now - rand(36000)

    assert cheque_vencido.vencido?, cheque_vencido.errors.messages

    assert_equal Cheque.count, 2
    assert_equal Cheque.vencidos.count, 1
  end

  test "los cheques propios no se depositan" do
    cheque = create :cheque, situacion: 'propio', estado: 'chequera'
    cuenta = create :cuenta

    assert_not cheque.depositar(cuenta)
  end

  test "los cheques de terceros no se pagan si estan en chequera" do
    cheque = create :cheque_de_terceros, estado: 'chequera'
    assert_not cheque.pagar, cheque.errors.messages
  end

  test 'pagar con un cheque extrae de la chequera' do
    cheque = build :cheque, monto: Money.new(100)
    recibo = create :recibo, situacion: 'pago', importe: Money.new(200)

    assert cheque.usar_para_pagar(recibo).persisted?
    assert_equal Money.new(-100), cheque.chequera.total
    assert recibo.movimientos.collect(&:monto).include? Money.new(-100)
  end

  test 'pagar un cheque extrae de su cuenta y salda la chequera' do
    cuenta = create :cuenta, :con_fondos
    chequera = cuenta.obra.chequera_propia
    cheque = cuenta.emitir_cheque(attributes_for(:cheque, monto: Money.new(100)))
    cheque.usar_para_pagar create(:recibo, importe: Money.new(100))

    assert cheque.pagar.persisted?, cheque.errors.messages

    assert cuenta.movimientos.collect(&:monto).include?(Money.new(-100))

    assert chequera.movimientos.collect(&:monto).include?(Money.new(100))
    assert_equal Money.new(0), chequera.total
  end

  test 'depositar un cheque extrae de la chequera' do
    otra_caja = create :cuenta
    cheque = create :cheque_de_terceros

    # asegurar que haya dinero disponible en la caja
    assert_nil cheque.cuenta

    resultado = cheque.depositar(otra_caja)

    assert_instance_of Cheque, resultado
    assert cheque.valid?, cheque.errors.messages
    assert_equal 'depositado', cheque.estado
    # al depositar un cheque, se asocia a una caja diferente
    assert_equal otra_caja, cheque.cuenta
    assert_equal cheque.monto, -1 * cheque.chequera.total
  end

  test 'cobrar un cheque depositado concreta el depósito' do
    cuenta = create :cuenta
    cheque = create :cheque_de_terceros
    assert cheque.depositar(cuenta).depositado?

    resultado = cheque.cobrar

    assert_instance_of Cheque, resultado
    assert cheque.valid?, cheque.errors.messages
    assert_equal 'cobrado', cheque.estado

    # deberia haber una salida de una caja y una entrada en otra
    assert_equal cheque.monto, cheque.chequera.total * -1
    assert_equal cheque.monto, cuenta.total
  end
end
