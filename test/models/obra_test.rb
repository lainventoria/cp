# encoding: utf-8
require 'test_helper'

class ObraTest < ActiveSupport::TestCase
  test 'es válida' do
    [ :build, :build_stubbed, :create].each do |metodo|
      assert_valid_factory metodo, :obra
    end
  end

  test 'crea sus cajas asociadas al crearse' do
    obra = create :obra

    assert_equal 8, obra.cajas.count
    assert_equal 1, obra.cajas.where(tipo: 'Obra').count
    assert_equal 1, obra.cajas.where(tipo: 'Administración').count
    assert_equal 1, obra.cajas.where(tipo: 'Seguridad').count
    assert_equal 1, obra.cajas.where(tipo: 'Caja de Ahorro').count
    assert_equal 1, obra.cajas.where(tipo: 'Chequera').count
    assert_equal 1, obra.cajas.where(tipo: 'Chequera propia').count
    assert_equal 1, obra.cajas.where(tipo: 'Retenciones de Ganancias').count
    assert_equal 1, obra.cajas.where(tipo: 'Retenciones de Cargas Sociales').count
  end

  test 'chequear saldos y totales' do
    obra = create :obra
    tercero = create :tercero
    5.times { obra.facturas.create(tercero: tercero, situacion: 'pago', importe_neto: Money.new(1000, 'ARS'), iva: Money.new(210, 'ARS')) }
    5.times { obra.facturas.create(tercero: tercero, situacion: 'cobro', importe_neto: Money.new(1000, 'ARS'), iva: Money.new(210, 'ARS')) }

    # todos los pagos son negativos, pero su iva es positivo
    assert_equal Money.new(1000 * -5),
                 obra.total_facturas('importe_neto', 'ARS', { situacion: 'pago' })
    assert_equal Money.new(210 * 5),
                 obra.total_facturas('iva', 'ARS', { situacion: 'pago' })

    # los cobros son positivos pero su iva es negativo
    assert_equal Money.new(1000 * 5),
                 obra.total_facturas('importe_neto', 'ARS', { situacion: 'cobro' })
    assert_equal Money.new(210 * -5),
                 obra.total_facturas('iva', 'ARS', { situacion: 'cobro' })

    # el balance da cero
    assert_equal Money.new(0),
                 obra.total_facturas('importe_neto', 'ARS')
    assert_equal Money.new(0),
                 obra.total_facturas('iva', 'ARS')

    assert_equal Money.new((1000 + 210) * -5), obra.saldo_de_pago
    assert_equal Money.new((1000 + 210) *  5), obra.saldo_de_cobro
    assert_equal Money.new(0), obra.saldo_general
  end

end
