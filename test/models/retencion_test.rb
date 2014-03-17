require 'test_helper'

class RetencionTest < ActiveSupport::TestCase
  test 'es válida' do
    [ :build, :build_stubbed, :create].each do |metodo|
      assert_valid_factory metodo, :retencion
    end
  end

  test "no se puede asociar a un cobro" do
    cobro = build :factura, situacion: 'cobro'

    refute build(:retencion, factura: cobro).valid?
  end

  test "se usa para pagar facturas" do
    retencion = create :retencion
    factura = create :factura, situacion: 'pago'

    recibo = retencion.pagar(factura)

    assert_instance_of Recibo, recibo
    assert_equal retencion.monto, recibo.importe
    assert_equal factura, retencion.factura_pagada
  end

  test "paga y guarda" do
    retencion = create :retencion
    factura = create :factura

    retencion.pagar(factura)
    assert retencion.changed?
    retencion.pagar!(factura)
    refute retencion.changed?
  end
end
