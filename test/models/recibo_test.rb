# encoding: utf-8
require 'test_helper'

class ReciboTest < ActiveSupport::TestCase
  test 'es válido' do
    [:build, :build_stubbed, :create].each do |metodo|
      assert_valid_factory metodo, :recibo
    end
  end

  test 'El recibo es válido si no completa la factura' do
    factura = create :factura, importe_neto: Money.new(1000), iva: Money.new(210)
    recibo = create :recibo, factura: factura
    recibo.movimientos.build monto: Money.new(800), caja: Caja.first, causa: Efectivo.new

    assert recibo.valid?, recibo.errors.messages
  end

  test 'El recibo es inválido si se pasa del valor de la factura' do
    factura = create :factura, importe_neto: Money.new(1000)
    recibo = create :recibo, factura: factura
    recibo.pagar_con efectivo_por Money.new(1800)

    assert recibo.invalid?, [ recibo.inspect, recibo.factura.inspect ]
    assert_not recibo.save, recibo.errors.messages
  end

  test 'La factura ya fue cancelada' do
    factura = create :factura, importe_neto: Money.new(1000), iva: Money.new(1000*0.21)
    aceptado = create :recibo, factura: factura
    aceptado.pagar_con efectivo_por(Money.new(1000*1.21))

    assert factura.reload.cancelada?
    rechazado = create :recibo, factura: factura
    rechazado.pagar_con efectivo_por(Money.new(800))

    assert aceptado.valid?, aceptado.errors.messages
    assert rechazado.invalid?, rechazado.errors.messages
  end

  test 'es un pago?' do
    recibo_pago = create :recibo, situacion: 'pago'
    recibo_cobro = build :recibo, situacion: 'cobro'

    assert recibo_pago.pago?
    assert_not recibo_cobro.pago?
  end

  test 'es un cobro?' do
    recibo_pago = create :recibo, situacion: 'pago'
    recibo_cobro = build :recibo, situacion: 'cobro'

    assert_not recibo_pago.cobro?
    assert recibo_cobro.cobro?
  end

  test 'crea recibos internos' do
    assert_difference 'Recibo.count' do
      recibo = Recibo.interno_nuevo
      assert_instance_of Recibo, recibo
      assert recibo.interno?
      assert_equal 0, recibo.importe
    end
  end
end
