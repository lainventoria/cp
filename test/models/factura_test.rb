require 'test_helper'

class FacturaTest < ActiveSupport::TestCase
  test "es válida" do
    # TODO arreglar las valicadiones en recibos y facturas
    assert (f = create(:factura)).valid?, f.errors.messages
  end

  test 'es un pago?' do
    assert build(:factura).pago?
  end

  test 'entonces no es cobro?' do
    assert_not build(:factura).cobro?
  end

  test "se cancela con recibos" do
    factura = create :factura, importe_neto: Money.new(3000), iva: Money.new(3000*0.21)
    3.times { create :recibo, factura: factura, importe: Money.new(1000*1.21) }

    assert factura.cancelada?
  end

  test "el saldo tiene que ser igual en memoria que en la bd" do
    factura = create :factura, importe_neto: Money.new(3000), iva: Money.new(3000*0.21)
    3.times { create :recibo, factura: factura, importe: Money.new(1000*1.21) }

    assert factura.valid?, factura.saldo
    assert factura.cancelada?
    assert factura.save
    assert factura.reload
    assert factura.cancelada?

  end

  test "desbloquear factura despues de cancelada" do
    factura = create :factura, importe_neto: Money.new(3000), iva: Money.new(3000*0.21)
    recibo = create :recibo, factura: factura, importe: Money.new(3000*1.21)

    assert factura.save

    factura.importe_neto = Money.new(4000)
    factura.iva = Money.new(4000*0.105)

    assert factura.save
    assert factura.reload

    recibo = create :recibo, factura: factura, importe: factura.saldo

    assert factura.save

  end

  test "se puede pagar" do
    factura = create :factura
    monto = factura.importe_total

    assert factura.recibos.empty?
    recibo = factura.pagar monto
    assert_equal monto, recibo.importe
    assert_equal 1, factura.recibos.count
  end

  test "no se puede pagar de más" do
    factura = create :factura
    monto = 2 * factura.importe_total

    assert factura.recibos.empty?
    recibo = factura.pagar monto
    assert_nil recibo
    assert_equal 0, factura.recibos.count
  end
end
