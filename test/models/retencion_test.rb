require 'test_helper'

class RetencionTest < ActiveSupport::TestCase
  setup do
    # Retención con factura para la mayoría de los tests
    @retencion = create :retencion
  end

  test 'es válida' do
    assert (r = build(:retencion)).valid?, r.errors.messages
  end
end
