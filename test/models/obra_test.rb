# encoding: utf-8
require 'test_helper'

class ObraTest < ActiveSupport::TestCase
  test 'es válida' do
    assert (o = build(:obra)).valid?, o.errors.messages
  end

  test 'crea su cuenta asociada al crearse' do
    obra = create :obra

    assert_instance_of Cuenta, obra.cuenta
    assert obra.cuenta.id == obra.id
  end

  test 'crea sus cajas asociadas al crearse' do
    obra = create :obra

    assert_equal 3, obra.cajas.count
    assert_equal 1, obra.cajas.where(tipo: 'De obra').count
    assert_equal 1, obra.cajas.where(tipo: 'De administración').count
    assert_equal 1, obra.cajas.where(tipo: 'De seguridad').count
  end
end
