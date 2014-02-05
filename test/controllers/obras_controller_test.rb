require 'test_helper'

class ObrasControllerTest < ActionController::TestCase
  setup do
    @obra = create :obra
  end

  test "accede a la lista de obras" do
    get :index
    assert_response :success
    assert_not_nil assigns(:obras)
  end

  test "accede a crear" do
    get :new
    assert_response :success
  end

  test "crea" do
    assert_difference('Obra.count') do
      post :create, obra: attributes_for(:obra)
    end

    assert_redirected_to obra_path(assigns(:obra))
  end

  test "muestra" do
    get :show, id: @obra
    assert_response :success
  end

  test "accede a editar" do
    get :edit, id: @obra
    assert_response :success
  end

  test "actualiza" do
    patch :update, id: @obra, obra: attributes_for(:obra)
    assert_redirected_to obra_path(assigns(:obra))
  end

  test "destruye" do
    assert_difference('Obra.count', -1) do
      delete :destroy, id: @obra
    end

    assert_redirected_to obras_path
  end
end
