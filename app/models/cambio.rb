# encoding: utf-8
class Cambio < CausaNoTrackeable
  include CausaDeMovimientos

  attr_accessor :indice

  validates_presence_of :monto, :caja
  validate :caja_es_una_cuenta

  def initialize(opciones = {})
    super
    @indice = opciones[:indice]
  end

  # Usa sus datos para transferir
  def operar
    if indice.present?
      caja.cambiar monto, moneda, indice
    else
      caja.cambiar_a_ojo monto, monto_aceptado
    end
  end

  private

    def caja_es_una_cuenta
      errors.add(:caja, :debe_ser_una_cuenta) unless caja.cuenta?
    end
end
