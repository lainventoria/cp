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

    # las cajas X van a ser ignoradas
    assert_equal 8, obra.cajas.count
    assert_equal 1, obra.cajas.where(tipo: 'Obra').count
    assert_equal 1, obra.cajas.where(tipo: 'Administración').count
    assert_equal 1, obra.cajas.where(tipo: 'Seguridad').count
    assert_equal 1, obra.cajas.where(tipo: 'Caja de Ahorro').count
    assert_equal 1, obra.cajas.where(tipo: 'Chequera').count
    assert_equal 1, obra.cajas.where(tipo: 'Chequera propia').count
    assert_equal 1, obra.cajas.where(tipo: 'Retenciones de Ganancias').count
    assert_equal 1, obra.cajas.where(tipo: 'Retenciones de Cargas Sociales').count
    # pero se pueden llamar aparte especificamente
    assert_equal 2, obra.cajas.where(tipo_factura: 'X').count

    assert_equal 1, obra.cajas.where(tipo: 'Administración X', tipo_factura: 'X').count
    assert_equal 1, obra.cajas.where(tipo: 'Chequera X', tipo_factura: 'X').count
  end
end
