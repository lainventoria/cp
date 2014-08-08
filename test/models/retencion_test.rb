# encoding: utf-8
require 'test_helper'

class RetencionTest < ActiveSupport::TestCase
  test 'es válida' do
    [ :build, :build_stubbed, :create].each do |metodo|
      assert_valid_factory metodo, :retencion
    end
  end

  test 'no se puede asociar a un cobro' do
    cobro = build :factura, situacion: 'cobro'

    refute build(:retencion, factura: cobro).valid?
  end

  test 'borrar retenciones borra sus movimientos' do
    recibo = create :recibo
    retencion = create :retencion, monto: Money.new(1000)
    recibo.pagar_con retencion

    assert recibo.movimientos.any?
    assert retencion.destroy
    assert recibo.reload.movimientos.count == 0
  end
end
