# encoding: utf-8
class Transferencia < CausaNoTrackeable
  include CausaDeMovimientos

  validates_presence_of :monto, :caja
  validate :caja_es_una_cuenta

  private

    def caja_es_una_cuenta
      errors.add(:caja, :debe_ser_una_cuenta) unless caja.cuenta?
    end
end
