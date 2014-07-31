# encoding: utf-8
class Transferencia < CausaNoTrackeable
  include CausaDeMovimientos

  validates_presence_of :monto, :caja
  validate :caja_es_una_cuenta

  # Puedo ofrecer pesos (monto), o dólares (monto) aceptados como pesos
  # (monto_aceptado). También intercambiando las monedas
  def usar_para_pagar(recibo)
    # Si ofrezco una moneda a cambio de la correspondiente a la factura, tengo
    # que cambiarla
    if monto_aceptado.try :nonzero?
      # Cambiamos la moneda y asociamos el recibo al recibo interno
      caja.cambiar(monto, monto_aceptado).update(recibo: recibo)
      self.monto = monto_aceptado
    end

    # Extraigo de la caja ya sea el pago correcto, o el pago aceptado que
    # generó el cambio
    if movimiento = caja.extraer(monto)
      movimiento.causa = self
      movimiento.recibo = recibo
      movimiento
    else
      false
    end
  end

  # Puedo aceptar pesos (monto), o dólares (monto) aceptados como pesos
  # (monto_aceptado). También intercambiando las monedas
  def usar_para_cobrar(recibo)
    # Si  cambiar, hacer el cambio interno y usar el nuevo valor de
    # monto
    if monto_aceptado.try :nonzero?
      caja.cambiar(monto_aceptado, monto)
      self.monto = monto_aceptado
    end

    if movimiento = caja.depositar(monto)
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
