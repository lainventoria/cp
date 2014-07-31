# encoding: utf-8
require 'test_helper'

class ReciboPagarConTest < ActiveSupport::TestCase
  setup do
    @factura = create :factura, situacion: 'pago'
    @recibo = create :recibo, factura: @factura
  end

  test 'se puede pagar con efectivo' do
    medio_de_pago = build :efectivo, monto: @factura.importe_total,
      caja: create(:caja, :con_fondos, monto: @factura.importe_total)

    assert_no_difference ->{ @recibo.reload.comprobantes.count } do
      assert @recibo.pagar_con(medio_de_pago)
    end
    assert @factura.reload.cancelada?
  end

  test 'se puede pagar con efectivo de otra moneda' do
    monto_recibido = Money.new(10, 'USD')
    medio_de_pago = build :efectivo, monto: monto_recibido,
      monto_aceptado: @factura.importe_total,
      caja: create(:caja, :con_fondos, monto: monto_recibido)

    assert_difference ->{ @recibo.reload.comprobantes.count } do
      assert @recibo.pagar_con(medio_de_pago)
    end
    assert @factura.reload.cancelada?
  end

  test 'se puede pagar con transferencia' do
    medio_de_pago = build :transferencia, monto: @factura.importe_total,
      caja: create(:caja, :con_fondos, monto: @factura.importe_total)

    assert_no_difference ->{ @recibo.reload.comprobantes.count } do
      assert @recibo.pagar_con(medio_de_pago)
    end
    assert @factura.reload.cancelada?
  end

  test 'se puede pagar con transferencia de otra moneda' do
    monto_recibido = Money.new(10, 'USD')
    medio_de_pago = build :transferencia, monto: monto_recibido,
      monto_aceptado: @factura.importe_total,
      caja: create(:caja, :con_fondos, monto: monto_recibido)

    assert_difference ->{ @recibo.reload.comprobantes.count } do
      assert @recibo.pagar_con(medio_de_pago)
    end
    assert @factura.reload.cancelada?
  end

  test 'no paga si factura y caja son de distinto tipo' do
    medio_de_pago = Efectivo.new monto: @factura.importe_total,
      caja: create(:caja, :con_fondos, monto: @factura.importe_total, tipo_factura: 'X')

    refute @recibo.pagar_con(medio_de_pago)
  end

  test 'paga si el tipo de factura y caja coinciden' do
    recibo = create :recibo, factura: create(:factura, situacion: 'pago', tipo: 'X')
    medio_de_pago = Efectivo.new monto: recibo.factura.importe_total,
      caja: create(:caja, :con_fondos, monto: recibo.factura.importe_total, tipo_factura: 'X')

    assert recibo.pagar_con(medio_de_pago), recibo.errors.messages
  end
end
