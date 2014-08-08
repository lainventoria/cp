# encoding: utf-8
require 'test_helper'

class ObrasControllerTest < ActionController::TestCase
  setup do
    @obra = create :obra
  end

  test 'accede a la lista de obras' do
    get :index
    assert_response :success
    assert_not_nil assigns(:obras)
  end

  test 'accede a crear' do
    get :new
    assert_response :success
  end

  test 'crea' do
    assert_difference('Obra.count') do
      post :create, obra: attributes_for(:obra)
    end

    assert_redirected_to obra_path(assigns(:obra))
  end

  test 'muestra' do
    get :show, id: @obra
    assert_response :success
  end

  test 'accede a editar' do
    get :edit, id: @obra
    assert_response :success
  end

  test 'actualiza' do
    patch :update, id: @obra, obra: attributes_for(:obra)
    assert_redirected_to obra_path(assigns(:obra))
  end

  test 'destruye' do
    # no se puede destruir hasta que nos hayamos sacado de encima las
    # facturas y las cajas
    assert_not @obra.destroy, @obra.errors.inspect
    assert @obra.facturas.destroy_all
    assert @obra.cajas.destroy_all

    assert_difference('Obra.count', -1) do
      delete :destroy, id: @obra
    end

    assert_redirected_to obras_path
  end
end
