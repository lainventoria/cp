require 'test_helper'

class FacturasControllerTest < ActionController::TestCase
  setup do
    @factura = create :factura
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create factura" do
    assert_difference('Factura.count') do
      post :create, factura: { tercero: @factura.tercero, descripcion: @factura.descripcion, situacion: @factura.situacion, fecha: @factura.fecha, fecha_pago: @factura.fecha_pago, importe_total: @factura.importe_total, iva: @factura.iva, numero: @factura.numero, tipo: @factura.tipo }
    end

    assert_redirected_to factura_path(assigns(:factura))
  end

  test "should show factura" do
    get :show, id: @factura
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @factura
    assert_response :success
  end

  test "should update factura" do
    patch :update, id: @factura, factura: { tercero: @factura.tercero, descripcion: @factura.descripcion, situacion: @factura.situacion, fecha: @factura.fecha, fecha_pago: @factura.fecha_pago, importe_total: @factura.importe_total, iva: @factura.iva, numero: @factura.numero, tipo: @factura.tipo }
    assert_redirected_to factura_path(assigns(:factura))
  end

  test "should destroy factura" do
    assert_difference('Factura.count', -1) do
      delete :destroy, id: @factura
    end

    assert_redirected_to facturas_path
  end
end
