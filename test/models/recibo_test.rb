require 'test_helper'

class ReciboTest < ActiveSupport::TestCase
  test "pagamos lo que corresponde" do
    factura = create :factura, importe_total: Money.new(3000)
    # 3 recibos de $1000 cada uno
    3.times { create :recibo, factura: factura, importe: Money.new(1000) }

    assert factura.cancelada?
  end
end
