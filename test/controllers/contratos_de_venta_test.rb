# encoding: utf-8
require 'test_helper'

class ContratosDeVentaControllerTest < ActionController::TestCase
  setup do
    @contrato = create :contrato_de_venta
    indice = create :indice
    indice.save
  end

  test 'accede a la lista de contratos' do
    get :index, obra_id: @contrato.obra
    assert_response :success
    assert_not_nil assigns(:contratos)
  end

  test 'accede a crear' do
    get :new, obra_id: @contrato.obra
    assert_response :success
  end

  test 'crea' do
    obra = create :obra
    unidad = create :unidad_funcional
    cuota = create :cuota
    tercero = create :tercero
    assert_difference('ContratoDeVenta.count') do
      post :create, obra_id: obra, 
      unidades_funcionales: [[unidad,{precio_venta:unidad.precio_venta}]],
      fechas: ['21/7/2014'],
      montos: [unidad.precio_venta],
      indice: 'anterior',
      contrato_de_venta: attributes_for(:contrato_de_venta, obra_id: obra, tercero_id: tercero)
    end
    contrato = assigns(:contrato)
    assert_redirected_to obra_contrato_de_venta_path(obra, contrato )
  end

  test 'muestra a través de su obra' do
    get :show, obra_id: @contrato.obra, id: @contrato
    assert_response :success
  end

  test 'accede a editar' do
    get :edit, id: @contrato, obra_id: @contrato.obra
    assert_response :success
  end

  test 'actualiza' do
    monto_original = @contrato.monto_total
    tercero = create :tercero
    patch :update, id: @contrato, obra_id: @contrato.obra, contrato_de_venta: { tercero_id: [tercero] }

    contrato = assigns(:contrato)
    assert_redirected_to obra_contrato_de_venta_path(contrato.obra,contrato)
    assert contrato.tercero = tercero
  end

  test 'destruye' do
    obra = @contrato.obra
    assert_difference('ContratoDeVenta.count', -1) do
      delete :destroy, id: @contrato, obra_id: @contrato.obra
    end

    assert_redirected_to obra_contratos_de_venta_path(obra)
  end
end

