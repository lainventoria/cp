require 'test_helper'

class CajaTest < ActiveSupport::TestCase
  test 'es válida' do
    assert (c = build(:caja)).valid?, c.errors.messages
  end
end
