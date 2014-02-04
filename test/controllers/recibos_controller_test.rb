require 'test_helper'

class RecibosControllerTest < ActionController::TestCase
  setup do
    factura = create :factura, importe_total: Money.new(3000)
    @recibo = create :recibo, factura: factura
  end

  test "should get index" do
    get :index, :factura_id => @recibo.factura.id
    assert_response :success
    assert_not_nil assigns(:recibos)
  end

  test "should get new" do
    get :new, :factura_id => @recibo.factura.id
    assert_response :success
  end

  test "should create recibo" do
    assert_difference('Recibo.count') do
      post :create, :factura_id => @recibo.factura.id, recibo: { situacion: @recibo.situacion, factura_id: @recibo.factura_id, fecha: @recibo.fecha, importe: Money.new(500) }
    end

    assert_redirected_to factura_recibo_path(@recibo.factura,assigns(:recibo))
  end

  test "should show recibo" do
    get :show, id: @recibo, :factura_id => @recibo.factura.id
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @recibo, :factura_id => @recibo.factura.id
    assert_response :success
  end

  test "should update recibo" do
    patch :update, id: @recibo, :factura_id => @recibo.factura.id, recibo: { situacion: @recibo.situacion, factura_id: @recibo.factura_id, fecha: @recibo.fecha, importe: Money.new(800) }
    assert_redirected_to factura_recibo_path(@recibo.factura,assigns(:recibo))
  end

  test "should destroy recibo" do
    assert_difference('Recibo.count', -1) do
      delete :destroy, id: @recibo, :factura_id => @recibo.factura.id
    end

    assert_redirected_to factura_recibos_path
  end
end
