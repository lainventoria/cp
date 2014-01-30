require 'test_helper'

class TercerosControllerTest < ActionController::TestCase
  setup do
    @tercero = create :tercero
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:terceros)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tercero" do
    assert_difference('Tercero.count') do
      post :create, tercero: { celular: @tercero.celular, cliente: @tercero.cliente, cuit: @tercero.cuit, direccion: @tercero.direccion, email: @tercero.email, iva: @tercero.iva, nombre: @tercero.nombre, proveedor: @tercero.proveedor, telefono: @tercero.telefono }
    end

    assert_redirected_to tercero_path(assigns(:tercero))
  end

  test "should show tercero" do
    get :show, id: @tercero
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tercero
    assert_response :success
  end

  test "should update tercero" do
    patch :update, id: @tercero, tercero: { celular: @tercero.celular, cliente: @tercero.cliente, cuit: @tercero.cuit, direccion: @tercero.direccion, email: @tercero.email, iva: @tercero.iva, nombre: @tercero.nombre, proveedor: @tercero.proveedor, telefono: @tercero.telefono }
    assert_redirected_to tercero_path(assigns(:tercero))
  end

  test "should destroy tercero" do
    assert_difference('Tercero.count', -1) do
      delete :destroy, id: @tercero
    end

    assert_redirected_to terceros_path
  end
end
