# encoding: utf-8
require 'test_helper'

class RetencionesControllerTest < ActionController::TestCase
  setup do
    @factura = create :factura, importe_neto: Money.new(3000), iva: Money.new(3000*0.21)
    @retencion = create :retencion, factura: @factura
  end

  test 'accede a la lista de retenciones globales' do
    get :index
    assert_response :success
    assert_not_nil assigns(:retenciones)
  end

  test 'accede a la lista de retenciones de la factura' do
    get :index, factura_id: @factura
    assert_response :success
    assert_not_nil assigns(:retenciones)
  end

  test 'accede a la lista de retenciones de la obra' do
    get :index, obra_id: @factura.obra
    assert_response :success
    assert_not_nil assigns(:retenciones)
  end

  test 'muestra' do
    get :show, id: @retencion
    assert_response :success
  end

  test 'muestra a través de su factura' do
    get :show, id: @retencion, factura_id: @factura
    assert_response :success
  end

  test 'no muestra a través de otra factura' do
    assert_raise ActiveRecord::RecordNotFound do
      get :show, id: @retencion, factura_id: create(:factura)
    end
  end

  test 'muestra a través de su obra' do
    get :show, obra_id: @retencion.obra, id: @retencion
    assert_response :success
  end

  test 'no muestra a través de otra obra' do
    # Rails devuelve un 404 por default con estos errores en producción
    assert_raise ActiveRecord::RecordNotFound do
      get :show, obra_id: create(:obra), id: @retencion
    end
  end
end
