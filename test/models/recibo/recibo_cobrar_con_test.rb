# encoding: utf-8
require 'test_helper'

class ReciboCobrarConTest < ActiveSupport::TestCase
  setup do
    @factura = create :factura, situacion: 'cobro'
    @recibo = create :recibo, factura: @factura
  end

  test 'se puede cobrar con efectivo' do
    caja = create(:caja)
    medio_de_cobro = build :efectivo, monto: @factura.importe_total,
      caja: caja

    assert_no_difference ->{ @recibo.reload.comprobantes.count } do
      assert @recibo.cobrar_con(medio_de_cobro)
    end
    assert @factura.reload.cancelada?
    assert_equal @factura.importe_total, caja.total
  end

  test 'se puede cobrar con efectivo de otra moneda' do
    monto_recibido = Money.new(10, 'USD')
    caja = create :caja, :con_fondos, monto: @factura.importe_total
    medio_de_cobro = build :efectivo, monto: monto_recibido,
      monto_aceptado: @factura.importe_total,
      caja: caja

    assert_difference ->{ @recibo.reload.comprobantes.count } do
      assert @recibo.cobrar_con(medio_de_cobro)
    end
    assert @factura.reload.cancelada?
    assert_equal monto_recibido, caja.total('USD')
  end

  test 'se puede cobrar con transferencia' do
    cuenta = create(:cuenta)
    medio_de_cobro = build :transferencia, monto: @factura.importe_total,
      caja: cuenta

    assert_no_difference ->{ @recibo.reload.comprobantes.count } do
      assert @recibo.cobrar_con(medio_de_cobro)
    end
    assert @factura.reload.cancelada?
    assert_equal @factura.importe_total, cuenta.total
  end

  test 'se puede cobrar con transferencia de otra moneda' do
    monto_recibido = Money.new(10, 'USD')
    cuenta = create :cuenta, :con_fondos, monto: @factura.importe_total
    medio_de_cobro = build :transferencia, monto: monto_recibido,
      monto_aceptado: @factura.importe_total,
      caja: cuenta

    assert_difference ->{ @recibo.reload.comprobantes.count } do
      assert @recibo.cobrar_con(medio_de_cobro)
    end
    assert @factura.reload.cancelada?
    assert_equal monto_recibido, cuenta.total('USD')
  end

  test 'no cobra si factura y caja son de distinto tipo' do
    medio_de_cobro = Efectivo.new monto: @factura.importe_total,
      caja: create(:caja, tipo_factura: 'X')

    refute @recibo.cobrar_con(medio_de_cobro)
  end

  test 'cobra si el tipo de factura y caja coinciden' do
    recibo = create :recibo, factura: create(:factura, situacion: 'pago', tipo: 'X')
    medio_de_cobro = Efectivo.new monto: recibo.factura.importe_total,
      caja: create(:caja, tipo_factura: 'X')

    assert recibo.cobrar_con(medio_de_cobro)
  end
end
