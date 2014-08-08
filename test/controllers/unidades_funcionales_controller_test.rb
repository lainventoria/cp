# encoding: utf-8
require 'test_helper'

class UnidadesFuncionalesControllerTest < ActionController::TestCase
  setup do
    @unidad = create :unidad_funcional
  end

  test 'accede a la lista de unidades' do
    get :index, obra_id: @unidad.obra
    assert_response :success
    assert_not_nil assigns(:unidades)
  end

  test 'accede a crear' do
    get :new, obra_id: @unidad.obra
    assert_response :success
  end

  test 'crea' do
    obra = create :obra
    assert_difference('UnidadFuncional.count') do
      post :create, obra_id: obra, unidad_funcional: attributes_for(:unidad_funcional, obra_id: obra)
    end
    unidad = assigns(:unidad)
    assert_redirected_to obra_unidad_funcional_path(obra, unidad )
  end

  test 'muestra a través de su obra' do
    get :show, obra_id: @unidad.obra, id: @unidad
    assert_response :success
  end

  test 'accede a editar' do
    get :edit, id: @unidad, obra_id: @unidad.obra
    assert_response :success
  end

  test 'actualiza' do
    patch :update, id: @unidad, obra_id: @unidad.obra, unidad_funcional: { tipo: 'Departamento' }
    unidad = assigns(:unidad)
    assert_redirected_to obra_unidad_funcional_path(unidad.obra,unidad)
    assert_equal 'Departamento', unidad.tipo
  end

  test 'destruye' do
    assert_difference('UnidadFuncional.count', -1) do
      delete :destroy, id: @unidad, obra_id: @unidad.obra
    end

    assert_redirected_to obra_unidades_funcionales_path(@unidad.obra)
  end
end
