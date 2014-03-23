require 'test_helper'

class ChequeTest < ActiveSupport::TestCase
  test "es válido" do
    [ :build, :build_stubbed, :create].each do |metodo|
      assert_valid_factory metodo, :cheque
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
    cheque = create :cheque
    cheque2 = create :cheque, fecha_vencimiento: Time.now - rand(36000)

    assert cheque2.vencido?, cheque2.errors.messages

    assert_equal Cheque.count, 2
    assert_equal Cheque.vencidos.count, 1

  end

  test "los cheques propios no se depositan" do
    cheque = create :cheque, situacion: 'propio', estado: 'chequera'
    caja = create :caja, situacion: 'banco'

    assert_not cheque.depositar(caja)
  end

  test "los cheques de terceros no se pagan si estan en chequera" do
    cheque = create :cheque, situacion: 'terceros', estado: 'chequera'
    assert_not cheque.pagar, cheque.errors.messages

  end

  test 'pagar un cheque genera movimientos en negativo' do
    cheque = create :cheque, situacion: 'propio'
    # asegurarse que haya algo en la caja
    assert cheque.caja.depositar(Money.new(2000, 'ARS'))
    monto = cheque.monto

    assert cheque.pagar, cheque.errors.messages
    assert cheque.recibo.movimientos.
             where(monto_centavos: cheque.monto_centavos * -1).
             where(monto_moneda: cheque.monto_moneda).any?

  end

  test 'cobrar un cheque genera una transferencia en otra caja' do
    otra_caja = create :caja, situacion: 'efectivo'
    caja = create :caja, situacion: 'chequera'
    # recordatorio: estuve una hora probando un monton de giladas solo
    # porque me habia olvidado de asignar la caja creada entonces estaba
    # tratando de transferir desde cualquier otra cosa!!!
    cheque = create :cheque, situacion: 'terceros', caja: caja # <= estupido fauno

    # asegurar que haya dinero disponible en la caja
    assert caja.depositar(cheque.monto)
    assert_equal cheque.monto, caja.total

    # al depositar un cheque, se asocia a una caja diferente
    assert cheque.depositar(otra_caja), cheque.errors.messages
    assert_equal 'depositado', cheque.estado
    assert_equal otra_caja, cheque.caja

    assert cheque.save, cheque.errors.messages
    assert cheque.reload

    # al cobrar un cheque, se devuelve un recibo interno y el cheque se
    # marca como cobrado
    assert (recibo_interno = cheque.cobrar), recibo_interno.errors.messages
    assert_equal 'cobrado', cheque.estado
    assert_equal 'interno', recibo_interno.situacion
    assert_equal 0, recibo_interno.importe

    # el recibo registra un movimiento de salida de una caja y entrada
    # en otra
    assert_equal 2, recibo_interno.movimientos.count, cheque.inspect
    assert recibo_interno.movimientos.
             where(monto_centavos: cheque.monto_centavos * -1).
             where(monto_moneda: cheque.monto_moneda).any?
    assert recibo_interno.movimientos.
             where(monto_centavos: cheque.monto_centavos).
             where(monto_moneda: cheque.monto_moneda).any?

    # deberia haber una salida de una caja y una entrada en otra
    assert_equal 0, caja.total
    assert_equal cheque.monto, otra_caja.total

  end

  test 'pasar un cheque de manos y despues pagarlo' do
    chequera = create :caja, situacion: 'chequera'
    cheque = create :cheque, situacion: 'terceros', caja: chequera
    recibo_de_pago = create :recibo, situacion: 'pago'

    assert chequera.depositar(cheque.monto)
    assert_equal recibo_de_pago, cheque.pasamanos(recibo_de_pago)
    assert_equal recibo_de_pago, cheque.destino
    assert recibo_de_pago.movimientos.where(caja_id: chequera).any?

    assert_equal 0, chequera.total
    assert recibo_de_pago.movimientos.
             where(monto_centavos: cheque.monto_centavos * -1).
             where(monto_moneda: cheque.monto_moneda).any?
  end
end
