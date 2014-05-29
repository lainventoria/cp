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

  test 'sabe detectar cuits inválidos' do
    refute Tercero.validar_cuit('10202234237')
  end

  test 'detecta si su cuit es inválido' do
    assert build(:tercero).cuit_valido?
  end

  test 'no permite cuits duplicados' do
    existente = create(:tercero)
    refute build(:tercero, cuit: existente.cuit).valid?
  end

  test 'entiende cuits sin guiones' do
    build(:tercero, cuit: '20312783224').valid?
  end
end
