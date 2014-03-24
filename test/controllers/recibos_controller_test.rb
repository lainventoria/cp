require 'test_helper'

class RecibosControllerTest < ActionController::TestCase
  setup do
    @factura = create :factura, importe_neto: Money.new(3000), iva: Money.new(3000*0.21)
    @recibo = create :recibo, factura: @factura
  end

  test "accede a la lista de recibos de la factura" do
    get :index, factura_id: @factura
    assert_response :success
    assert_not_nil assigns(:recibos)
  end

  test "accede a crear" do
    get :new, factura_id: @factura
    assert_response :success
  end

  test "crea" do
    importe_permitido = @factura.saldo
    assert_difference('Recibo.count') do
      post :create, factura_id: @factura, recibo: attributes_for(
        :recibo, importe: importe_permitido, factura_id: @factura)
    end

    assert_redirected_to factura_recibo_path(@recibo.factura, assigns(:recibo))
  end

  test "muestra" do
    get :show, id: @recibo, factura_id: @factura
    assert_response :success
  end

  test "accede a editar" do
    get :edit, id: @recibo, factura_id: @factura
    assert_response :success
  end

  test "actualiza" do
    importe_permitido = @factura.saldo
    patch :update, id: @recibo, factura_id: @factura, recibo: attributes_for(
      :recibo, importe: importe_permitido, factura_id: @factura)
    assert_redirected_to factura_recibo_path(@recibo.factura,assigns(:recibo))
  end

  test "destruye" do
    assert_difference('Recibo.count', -1) do
      delete :destroy, id: @recibo, factura_id: @factura
    end

    assert_redirected_to factura_path
  end
end
