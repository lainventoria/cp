require 'test_helper'

class CajasControllerTest < ActionController::TestCase
  setup do
    @caja = create :caja
  end

  test "accede a la lista de cajas" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cajas)
  end

  test "accede a crear" do
    get :new
    assert_response :success
  end

  test "crea" do
    obra = create :obra
    assert_difference('Caja.count') do
      post :create, caja: attributes_for(:caja, obra_id: obra)
    end

    assert_redirected_to caja_path(assigns(:caja))
  end

  test "muestra" do
    get :show, id: @caja
    assert_response :success
  end

  test "muestra a través de su obra" do
    get :show, obra_id: @caja.obra, id: @caja
    assert_response :success
  end

  test "no muestra a través de otra obra" do
    # Rails devuelve un 404 por default con estos errores en producción
    assert_raise ActiveRecord::RecordNotFound do
      get :show, obra_id: create(:obra), id: @caja
    end
  end

  test "accede a editar" do
    get :edit, id: @caja
    assert_response :success
  end

  test "actualiza" do
    patch :update, id: @caja, caja: { tipo: 'Otro' }
    assert_redirected_to caja_path(caja = assigns(:caja))

    assert_equal 'Otro', caja.tipo
  end

  test "destruye" do
    # vaciamiento :P
    @caja.totales.each do |total|
      assert @caja.extraer!(total[1])
    end

    assert_difference('Caja.count', 0) do
      delete :destroy, id: @caja
    end

    # no nos llega el archivada = true hasta que recargamos la caja
    assert @caja.reload
    assert_equal true, @caja.archivada

    assert_redirected_to obra_cajas_path(@caja.obra)
  end
end
