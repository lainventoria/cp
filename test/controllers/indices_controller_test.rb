# encoding: utf-8
require 'test_helper'

class IndicesControllerTest < ActionController::TestCase
  setup do
    @indice = create :indice
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:indices)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create indice' do
    assert_difference('Indice.count') do
      post :create, indice: { denominacion: @indice.denominacion, periodo: @indice.periodo, valor: @indice.valor }
    end

    assert_redirected_to indice_path(assigns(:indice))
  end

  test 'should show indice' do
    get :show, id: @indice
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @indice
    assert_response :success
  end

  test 'should update indice' do
    patch :update, id: @indice, indice: { denominacion: @indice.denominacion, periodo: @indice.periodo, valor: @indice.valor }
    assert_redirected_to indice_path(assigns(:indice))
  end

  test 'should destroy indice' do
    assert_difference('Indice.count', -1) do
      delete :destroy, id: @indice
    end

    assert_redirected_to indices_path
  end

end
