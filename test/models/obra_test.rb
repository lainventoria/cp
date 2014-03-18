# encoding: utf-8
require 'test_helper'

class ObraTest < ActiveSupport::TestCase
  test 'es válida' do
    assert (o = build(:obra)).valid?, o.errors.messages
  end

  test 'crea sus cajas asociadas al crearse' do
    obra = create :obra

    assert_equal 5, obra.cajas.count
    assert_equal 1, obra.cajas.where(tipo: 'De obra').count
    assert_equal 1, obra.cajas.where(tipo: 'De administración').count
    assert_equal 1, obra.cajas.where(tipo: 'De seguridad').count
    assert_equal 1, obra.cajas.where(tipo: 'Caja de Ahorro').count
    assert_equal 1, obra.cajas.where(tipo: 'Chequera').count
  end
end
