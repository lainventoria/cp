require 'test_helper'

class ReciboTest < ActiveSupport::TestCase
  test "es válido" do
    [ :build, :build_stubbed, :create].each do |metodo|
      assert_valid_factory metodo, :recibo
    end
  end

  test "El recibo es válido si no completa la factura" do
    factura = create :factura, importe_neto: Money.new(1000)
    recibo = factura.recibos.build importe: Money.new(800)

    assert recibo.valid?, recibo.errors.messages
    assert recibo.save
    assert recibo.reload.valid?, recibo.errors.messages
  end

  test "El recibo es inválido si se pasa del valor de la factura" do
    factura = create :factura, importe_neto: 1000
    recibo = factura.recibos.build importe: 1800

    assert recibo.invalid?, [ recibo.inspect, recibo.factura.inspect ]
    assert_not recibo.save
  end

  test "La factura ya fue cancelada" do
    factura = create :factura, importe_neto: 1000, iva: 1000*0.21
    recibo1 = factura.recibos.build importe: 1000*1.21
    recibo2 = factura.recibos.build importe: 800

    assert recibo1.valid?, recibo1.errors.messages
    assert recibo1.save
    assert recibo2.invalid?, [ recibo2.inspect, recibo2.factura.inspect ]
    assert_not recibo2.save
  end

  test "es un pago?" do
    recibo_pago = create :recibo, situacion: "pago"
    recibo_cobro = build :recibo, situacion: "cobro"

    assert recibo_pago.pago?
    assert_not recibo_cobro.pago?
  end

  test "es un cobro?" do
    recibo_pago = create :recibo, situacion: "pago"
    recibo_cobro = build :recibo, situacion: "cobro"

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
