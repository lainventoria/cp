# encoding: utf-8
class Transferencia < PagoNoTrackeable
  include CausaDeMovimientos

  validates_presence_of :monto, :caja
  validate :caja_es_una_cuenta

  def usar_para_pagar(recibo)
    # Si vamos a cambiar, hacer el cambio interno y usar el nuevo valor de
    # monto
    if monto_aceptado.try :nonzero?
      caja.cambiar_a_ojo(monto, monto_aceptado)
      self.monto = monto_aceptado
    end

    if movimiento = caja.extraer(monto)
      movimiento.causa = self
      movimiento.recibo = recibo
      movimiento
    else
      false
    end
  end

  private

    def caja_es_una_cuenta
      errors.add(:caja, :debe_ser_una_cuenta) unless caja.cuenta?
    end
end
