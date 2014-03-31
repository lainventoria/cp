require 'test_helper'

class FacturasControllerTest < ActionController::TestCase
  setup do
    @factura = create :factura
  end

  test "accede a nueva factura" do
    get :new
    assert_response :success
  end

  test "crea" do
    assert_difference('Factura.count') do
      post :create, factura: { tercero: @factura.tercero, descripcion: @factura.descripcion, situacion: @factura.situacion, fecha: @factura.fecha, fecha_pago: @factura.fecha_pago, importe_total: @factura.importe_total, iva: @factura.iva, numero: @factura.numero, tipo: @factura.tipo }
    end

    assert_redirected_to factura_path(assigns(:factura))
  end

  test "muestra" do
    get :show, id: @factura
    assert_response :success
  end

  test "muestra a través de su obra" do
    get :show, obra_id: @factura.obra, id: @factura
    assert_response :success
  end

  test "no muestra a través de otra obra" do
    # Rails devuelve un 404 por default con estos errores en producción
    assert_raise ActiveRecord::RecordNotFound do
      get :show, obra_id: create(:obra), id: @factura
    end
  end

  test "accede a editar" do
    get :edit, id: @factura
    assert_response :success
  end

  test "actualiza" do
    patch :update, id: @factura, factura: { tercero: @factura.tercero, descripcion: @factura.descripcion, situacion: @factura.situacion, fecha: @factura.fecha, fecha_pago: @factura.fecha_pago, importe_total: @factura.importe_total, iva: @factura.iva, numero: @factura.numero, tipo: @factura.tipo }
    assert_redirected_to factura_path(assigns(:factura))
  end

  test "destruye" do
    ruta = if @factura.pago?
      pagos_facturas_path
    else
      cobros_facturas_path
    end

    assert_difference('Factura.count', -1) do
      delete :destroy, id: @factura
    end

    assert_redirected_to ruta
  end
end
