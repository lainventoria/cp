require 'test_helper'

class ReciboTest < ActiveSupport::TestCase
  test "es válido" do
    assert (r = create(:recibo)).valid?, r.errors.messages
  end

  test "El recibo es válido si no completa la factura" do
    factura = create :factura, importe_total: Money.new(1000)
    recibo = factura.recibos.build importe: Money.new(800)

    assert recibo.valid?, recibo.errors.messages
    assert recibo.save
    assert recibo.reload.valid?, recibo.errors.messages
  end

  test "El recibo es inválido si se pasa del valor de la factura" do
    factura = create :factura, importe_total: 1000
    recibo = factura.recibos.build importe: 1800

    assert recibo.invalid?, recibo.errors.messages
    assert_not recibo.save
  end

  test "La factura ya fue cancelada" do
    factura = create :factura, importe_total: 1000
    recibo1 = factura.recibos.build importe: 1000
    recibo2 = factura.recibos.build importe: 800

    assert recibo1.valid?, recibo1.errors.messages
    assert recibo1.save
    assert recibo2.invalid?, recibo2.errors.messages
    assert_not recibo2.save
  end
end
