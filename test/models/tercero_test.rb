require 'test_helper'

class TerceroTest < ActiveSupport::TestCase

  test 'es válido' do
     [ :build, :build_stubbed, :create].each do |metodo|
      assert_valid_factory metodo, :tercero
    end
  end

  test "valida el funcionamiento de proveedor? y cliente?" do
    @proveedor = create :tercero, relacion: "proveedor", cuit: "75-00000000-0"
    @cliente = create :tercero, relacion: "cliente", cuit: "70-00004000-0"
    @ambos = create :tercero, relacion: "ambos", cuit: "40-00007000-0"

    assert @proveedor.proveedor?
    assert_not @cliente.proveedor?
    assert @ambos.proveedor?

    assert_not @proveedor.cliente?
    assert @cliente.cliente?
    assert @ambos.cliente?
  end
end
