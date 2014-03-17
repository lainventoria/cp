ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/mock'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!
  # Add more helper methods to be used by all tests here...

  # permite usar create, build, etc directamente
  include FactoryGirl::Syntax::Methods

  # Prueba que la fábrica construya objetos válidos, :build por default
  def assert_valid_factory(metodo, tipo)
    coso = FactoryGirl.send(metodo, tipo)
    assert coso.valid?, "#{metodo}: #{coso.errors.messages.inspect}"
  end
end
