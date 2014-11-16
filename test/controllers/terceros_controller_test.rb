# encoding: utf-8
require 'test_helper'

class TercerosControllerTest < ActionController::TestCase
  setup do
    @tercero = create :tercero
  end

  test 'accede a la lista' do
    get :index
    assert_response :success
    assert_not_nil assigns(:terceros)
  end

  test 'accede a crear' do
    get :new
    assert_response :success
  end

  test 'crea' do
    assert_difference('Tercero.count') do
      post :create, tercero: attributes_for(:tercero)
    end

    assert_redirected_to tercero_path(assigns(:tercero))
  end

  test 'muestra' do
    get :show, id: @tercero
    assert_response :success
  end

  test 'accede a editar' do
    get :edit, id: @tercero
    assert_response :success
  end

  test 'actualiza' do
    atributos = attributes_for :tercero, :completo

    patch :update, id: @tercero, tercero: atributos

    assert_redirected_to tercero_path(assigns(:tercero))
    assert_equal atributos[:celular], @tercero.reload.celular
    assert_equal atributos[:relacion], @tercero.relacion
    assert_equal atributos[:cuit], @tercero.cuit
    assert_equal atributos[:direccion], @tercero.direccion
    assert_equal atributos[:email], @tercero.email
    assert_equal atributos[:iva], @tercero.iva
    assert_equal atributos[:nombre], @tercero.nombre
    assert_equal atributos[:telefono], @tercero.telefono
    assert_equal atributos[:contacto], @tercero.contacto
    assert_equal atributos[:notas], @tercero.notas
  end

  test 'destruye' do
    assert_difference('Tercero.count', -1) do
      delete :destroy, id: @tercero
    end

    assert_redirected_to terceros_path
  end

  test 'no crea un nuevo tercero con un cuit existente' do
    assert_no_difference('Tercero.count') do
      post :create, tercero: attributes_for(:tercero, cuit: @tercero.cuit)
    end
  end
end
