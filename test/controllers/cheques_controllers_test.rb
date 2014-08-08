# encoding: utf-8
require 'test_helper'

class ChequesControllerTest < ActionController::TestCase
  setup do
    @cheque = create :cheque
  end

  test 'lista de cheques' do
    get :index
    assert_response :success
  end

  test 'mostrar' do
    get :show, obra_id: @cheque.chequera.obra, caja_id: @cheque.chequera, id: @cheque

    assert_response :success
  end

  test 'muestra a través de su caja' do
    get :show, obra_id: @cheque.chequera.obra, caja_id: @cheque.chequera, id: @cheque
    assert_response :success
  end

  test 'no muestra a través de otra obra' do
    # Rails devuelve un 404 por default con estos errores en producción
    assert_raise ActiveRecord::RecordNotFound do
      get :show, obra_id: create(:obra), caja_id: create(:caja), id: @cheque
    end
  end

  test 'deposita' do
    patch :depositar, obra_id: @cheque.chequera.obra,
          caja_id: @cheque.chequera, id: @cheque,
          cheque: { cuenta_id: create(:caja) }

    assert_response :success
  end

  test 'cobra' do
    patch :cobrar, obra_id: @cheque.chequera.obra,
          caja_id: @cheque.chequera, id: @cheque

    assert_response :success
  end

  test 'paga' do
    @cheque.cuenta = create(:cuenta, :con_fondos, monto: @cheque.monto)
    assert @cheque.save, @cheque.errors.messages
    patch :pagar, obra_id: @cheque.chequera.obra,
          caja_id: @cheque.chequera, id: @cheque

    assert_redirected_to obra_cheques_path(@cheque.chequera.obra, situacion: 'propio')
  end

  test 'paga sin fondos y que falle' do
    @cheque.cuenta = create(:cuenta, :con_fondos, monto: @cheque.monto / 2)
    assert @cheque.save, @cheque.errors.messages
    patch :pagar, obra_id: @cheque.chequera.obra,
          caja_id: @cheque.chequera, id: @cheque

    assert assigns(:cheque).errors.count > 0
  end
end
