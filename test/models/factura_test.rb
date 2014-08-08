# encoding: utf-8
require 'test_helper'

class FacturaTest < ActiveSupport::TestCase
  test 'es válida' do
    [ :build, :build_stubbed, :create].each do |metodo|
      assert_valid_factory metodo, :factura
    end
  end

  test 'es un pago?' do
    @pago = create :factura, situacion: 'pago'
    @cobro = create :factura, situacion: 'cobro'

    assert @pago.pago?
    assert_not @cobro.pago?
  end

  test 'es un cobro?' do
    @pago = create :factura, situacion: 'pago'
    @cobro = create :factura, situacion: 'cobro'

    assert_not @pago.cobro?
    assert @cobro.cobro?
  end

  test 'se cancela con recibos' do
    factura = create :factura, importe_neto: Money.new(2000), iva: Money.new(2000*0.21)
    2.times do
      recibo = create :recibo, factura: factura
      recibo.pagar_con efectivo_por(Money.new(1000*1.21))
    end

    assert factura.reload.cancelada?
    # testbombing!
    assert_not Factura.por_saldar.include? factura
    assert Factura.saldadas.include? factura
  end

  test 'desbloquear factura despues de cancelada' do
    factura = create :factura, importe_neto: Money.new(3000), iva: Money.new(3000*0.21)
    recibo = create :recibo, factura: factura
    recibo.pagar_con efectivo_por(Money.new(3000*1.21))

    assert factura.reload.cancelada?

    factura.importe_neto = Money.new(4000)
    factura.iva = Money.new(4000*0.105)
    assert factura.save

    assert_not factura.reload.cancelada?

    recibo = create :recibo, factura: factura
    recibo.pagar_con efectivo_por(factura.saldo)
    assert factura.save

    assert factura.reload.cancelada?
  end
end
