require 'test_helper'

class CajasControllerTest < ActionController::TestCase
  setup do
    @caja = create :caja
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cajas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create caja" do
    assert_difference('Caja.count') do
      post :create, caja: { obra_id: @caja.obra_id }
    end

    assert_redirected_to caja_path(assigns(:caja))
  end

  test "should show caja" do
    get :show, id: @caja
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @caja
    assert_response :success
  end

  test "should update caja" do
    patch :update, id: @caja, caja: { obra_id: @caja.obra_id }
    assert_redirected_to caja_path(assigns(:caja))
  end

  test "should destroy caja" do
    assert_difference('Caja.count', -1) do
      delete :destroy, id: @caja
    end

    assert_redirected_to cajas_path
  end
end
