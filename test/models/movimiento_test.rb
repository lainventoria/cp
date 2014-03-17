# encoding: utf-8
require 'test_helper'

class MovimientoTest < ActiveSupport::TestCase
  test 'es válido' do
    [ :build, :build_stubbed, :create].each do |metodo|
      assert_valid_factory metodo, :movimiento
    end
  end

  test 'usa pesos argentinos por default' do
    assert_equal 'ARS', build(:movimiento).monto_moneda
  end

  test 'puede usar dólares' do
    dolar = build(:movimiento, monto: Money.new(100, 'USD')) # 1 dólar
    assert dolar.valid?
    assert_equal 'USD', dolar.monto_moneda
    assert_equal 100, dolar.monto_centavos
    assert_equal Money.new(100, 'USD'), dolar.monto
  end
end
