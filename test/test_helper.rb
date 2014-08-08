# encoding: utf-8
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/mock'
require 'database_cleaner'

# Borrar todas las tablas de la DB
DatabaseCleaner.clean_with :truncation

class ActiveSupport::TestCase
  # Permite usar create, build, etc directamente
  include FactoryGirl::Syntax::Methods

  ActiveRecord::Migration.check_pending!

  setup do
    # Iniciar la transacción
    DatabaseCleaner.start
  end

  teardown do
    # Rollbackear así el siguiente test está con estado limpio
    DatabaseCleaner.clean
  end

  # Prueba que la fábrica construya objetos válidos, :build por default
  def assert_valid_factory(metodo, tipo)
    coso = FactoryGirl.send(metodo, tipo)
    assert coso.valid?, "#{metodo}: #{coso.errors.messages.inspect}"
  end

  def efectivo_por(monto)
    Efectivo.new caja: create(:caja, :con_fondos), monto: monto
  end
end
