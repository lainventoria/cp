require 'test_helper'

class TerceroTest < ActiveSupport::TestCase

  test 'es válido' do
     [ :build, :build_stubbed, :create].each do |metodo|
      assert_valid_factory metodo, :tercero
    end
  end

  test 'sabe si es un proveedor' do
    proveedor = create :proveedor

    assert proveedor.proveedor?
    refute proveedor.cliente?
  end

  test 'sabe si es un cliente' do
    cliente = create :cliente

    assert cliente.cliente?
    refute cliente.proveedor?
  end

  test 'ambos es tanto cliente como proveedor' do
    ambos = create(:tercero, relacion: 'ambos')

    assert ambos.proveedor?
    assert ambos.cliente?
  end
end
