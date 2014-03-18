require 'test_helper'

class ChequesControllerTest < ActionController::TestCase
  setup do
    @caja = create :caja
    @cheque = create :cheque
  end

  test "lista de cheques" do
    get :index
    assert_response :success
  end

  test "mostrar" do
    get :show, id: @cheque

    assert_response :success
  end
end