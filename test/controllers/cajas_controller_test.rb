require 'test_helper'

class CajasControllerTest < ActionController::TestCase
  setup do
    @caja = create :caja
    @obra = @caja.obra
  end

  test "accede a la lista de cajas de la obra" do
    get :index, obra_id: @obra
    assert_response :success
    assert_not_nil assigns(:cajas)
  end

  test "accede a crear" do
    get :new, obra_id: @obra
    assert_response :success
  end

  test "crea" do
    assert_difference('Caja.count') do
      post :create, obra_id: @obra, caja: { tipo: 'sarasa' }
    end

    assert_redirected_to obra_caja_path(@obra, assigns(:caja))
  end

  test "muestra" do
    get :show, obra_id: @obra, id: @caja
    assert_response :success
  end

  test "accede a editar" do
    get :edit, obra_id: @obra, id: @caja
    assert_response :success
  end

  test "actualiza" do
    patch :update, obra_id: @obra, id: @caja, caja: { obra_id: @caja.obra_id }
    assert_redirected_to obra_caja_path(@obra, assigns(:caja))
  end

  test "destruye" do
    assert_difference('Caja.count', -1) do
      delete :destroy, obra_id: @obra, id: @caja
    end

    assert_redirected_to obra_cajas_path(@obra)
  end
end
