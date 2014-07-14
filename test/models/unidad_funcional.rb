# encoding: utf-8
require 'test_helper'

class UnidadFuncionalTest < ActiveSupport::TestCase

  test 'es válida' do
     [ :build, :build_stubbed, :create ].each do |metodo|
      assert_valid_factory metodo, :unidad_funcional
    end
  end

  test "cada unidad se vende a un solo tercero" do
    uf = create :unidad_funcional
    cv = create :contrato_de_venta

    assert cv.agregar_unidad_funcional(uf)
    assert cv.save, cv.errors.messages.inspect
    # medio al pedo porque uf.tercero viene de cv.tercero pero lo dejo
    # así por si cambia la api
    assert_equal cv.tercero, uf.tercero
  end

  test "hay unidades estan disponibles" do
    uf = create :unidad_funcional

    assert_equal 1, UnidadFuncional.disponibles.count
  end

  test "cuando se venden dejan de estar disponibles" do
    uf = create :unidad_funcional
    cv = create :contrato_de_venta

    assert cv.agregar_unidad_funcional(uf)
    assert cv.save

    assert_equal 0, UnidadFuncional.disponibles.count
    assert_not_equal 0, UnidadFuncional.vendidas.count
  end

end
