# encoding: utf-8
require 'test_helper'

class ReciboPagarConTest < ActiveSupport::TestCase
  setup do
    @factura = create :factura, situacion: 'pago'
  end

  test "se puede pagar con efectivo" do
    recibo = create :recibo, factura: @factura
    medio_de_pago = Efectivo.new monto: @factura.importe_total,
      caja: create(:caja, :con_fondos, monto: @factura.importe_total)

    assert recibo.pagar_con(medio_de_pago)
  end

  test "no pagar facturas a en cajas x" do
    recibo = create :recibo, factura: @factura
    medio_de_pago = Efectivo.new monto: @factura.importe_total,
      caja: create(:caja, :con_fondos, monto: @factura.importe_total, tipo_factura: 'X')

    assert_not recibo.pagar_con(medio_de_pago)
  end

  test "pagar facturas x en cajas x" do
    recibo = create :recibo, factura: create(:factura, situacion: 'pago', tipo: 'X')
    medio_de_pago = Efectivo.new monto: recibo.factura.importe_total,
      caja: create(:caja, :con_fondos, monto: recibo.factura.importe_total, tipo_factura: 'X')

    assert recibo.pagar_con(medio_de_pago), recibo.errors.messages
  end
end
