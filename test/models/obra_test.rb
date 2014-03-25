# encoding: utf-8
require 'test_helper'

class ObraTest < ActiveSupport::TestCase
  test 'es válida' do
    assert (o = build(:obra)).valid?, o.errors.messages
  end

  test 'crea sus cajas asociadas al crearse' do
    obra = create :obra

    assert_equal 5, obra.cajas.count
    assert_equal 1, obra.cajas.where(tipo: 'Obra').count
    assert_equal 1, obra.cajas.where(tipo: 'Administración').count
    assert_equal 1, obra.cajas.where(tipo: 'Seguridad').count
    assert_equal 1, obra.cajas.where(tipo: 'Caja de Ahorro').count
    assert_equal 1, obra.cajas.where(tipo: 'Chequera').count
  end

  test 'chequear los saldos' do
    obra = create :obra
    5.times { obra.facturas.create(situacion: 'pago', importe_neto: Money.new(1000), iva: Money.new(210)) }
    5.times { obra.facturas.create(situacion: 'cobro', importe_neto: Money.new(1000), iva: Money.new(210)) }

    assert_equal Money.new((1000 + 210) * -5), obra.saldo_de_pago
    assert_equal Money.new((1000 + 210) *  5), obra.saldo_de_cobro
    assert_equal Money.new(0), obra.saldo_general
  end

end
