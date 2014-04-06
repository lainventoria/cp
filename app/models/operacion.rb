# encoding: utf-8
class Operacion < CausaNoTrackeable
  include CausaDeMovimientos

  validates_presence_of :monto, :caja

  # Usa sus datos para transferir
  def cambiar
    caja.cambiar monto, monto_aceptado
  end

  # Usa sus datos para transferir
  def transferir
    caja.transferir monto, caja_destino
  end
end
