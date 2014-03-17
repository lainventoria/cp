require 'test_helper'

class RetencionTest < ActiveSupport::TestCase
  setup do
    # Retención con factura para la mayoría de los tests
    @retencion = create :retencion
  end

  test 'es válida' do
    [ :build, :build_stubbed, :create].each do |metodo|
      assert_valid_factory metodo, :retencion
    end
  end

  test "se usa para pagar facturas" do
    factura = create :factura

    recibo = @retencion.pagar(factura)

    assert_instance_of Recibo, recibo
    assert_equal @retencion.monto, recibo.importe
    assert_equal factura, @retencion.factura_pagada
  end

  test "paga y guarda" do
    factura = create :factura

    @retencion.pagar(factura)
    assert @retencion.changed?
    @retencion.pagar!(factura)
    refute @retencion.changed?
  end
end
