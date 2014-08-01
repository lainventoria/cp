# encoding: utf-8
class Efectivo < CausaNoTrackeable
  include CausaDeMovimientos

  validates_presence_of :monto, :caja
  validate :caja_es_de_efectivo

  private

    def caja_es_de_efectivo
      errors.add(:caja, :debe_ser_de_efectivo) unless caja.efectivo?
    end
end
