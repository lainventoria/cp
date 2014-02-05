class Obra < ActiveRecord::Base
  has_many :cajas
  has_one :cuenta

  after_create :create_cuenta, :crear_cajas

  validates_presence_of :nombre, :direccion

  private

    def crear_cajas
      ['De obra', 'De administración', 'De seguridad'].each do |tipo|
        cajas.create tipo: tipo
      end
    end
end
