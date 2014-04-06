# encoding: utf-8
require 'test_helper'

class ObrasTotalesTest < ActiveSupport::TestCase
  setup do
    @obra = create :obra
    @tercero = create :tercero
    5.times { @obra.facturas.create(tercero: @tercero, situacion: 'pago', importe_neto: Money.new(1000, 'ARS'), iva: Money.new(210, 'ARS')) }
    5.times { @obra.facturas.create(tercero: @tercero, situacion: 'cobro', importe_neto: Money.new(1000, 'ARS'), iva: Money.new(210, 'ARS')) }
  end

  test "todos los pagos y su iva son positivos" do
    assert_equal Money.new(1000 * 5),
                 @obra.total_facturas('importe_neto', 'ARS', { situacion: 'pago' })
    assert_equal Money.new(210 * 5),
                 @obra.total_facturas('iva', 'ARS', { situacion: 'pago' })
  end

  test "los cobros y su iva son positivos" do
    assert_equal Money.new(1000 * 5),
                 @obra.total_facturas('importe_neto', 'ARS', { situacion: 'cobro' })
    assert_equal Money.new(210 * 5),
                 @obra.total_facturas('iva', 'ARS', { situacion: 'cobro' })
  end

  test "los saldos de pago no son negativos" do
    assert_equal Money.new((1000 + 210) * 5), @obra.saldo_de_pago
  end

  test "los saldos de pago son positivos" do
    assert_equal Money.new((1000 + 210) *  5), @obra.saldo_de_cobro
  end

  test "los saldos totales son ni fu ni fa" do
    assert_equal Money.new(0), @obra.saldo_general
  end
end
