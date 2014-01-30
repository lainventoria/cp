require 'test_helper'

class FacturaTest < ActiveSupport::TestCase
  test 'es un pago?' do
    assert build(:factura).pago?
  end

  test 'entonces no es cobro?' do
    assert_not build(:factura).cobro?
  end
end
