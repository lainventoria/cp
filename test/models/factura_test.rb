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
    factura = create :factura, importe_total: Money.new(3000)
    3.times { create :recibo, factura: factura, importe: Money.new(1000) }

    assert factura.cancelada?
  end
end
