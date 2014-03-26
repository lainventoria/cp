# encoding: utf-8
class Obra < ActiveRecord::Base
  has_many :cajas
  has_one :chequera_propia, ->{ where(tipo: 'Chequera propia') },
    class_name: 'Caja'

  after_create :crear_cajas

  validates_presence_of :nombre, :direccion

  private

    def crear_cajas
      ['Obra', 'Administración', 'Seguridad'].each do |tipo|
        cajas.create tipo: tipo, situacion: 'efectivo'
      end

      cajas.create tipo: 'Caja de Ahorro', situacion: 'banco'
      cajas.create tipo: 'Chequera', situacion: 'chequera'
      cajas.create tipo: 'Chequera propia', situacion: 'chequera'
    end
end
