# encoding: utf-8
class Efectivo < CausaNoTrackeable
  include CausaDeMovimientos

  validates_presence_of :monto, :caja
  validate :caja_es_de_efectivo

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
    # El cambio es a la inversa que en pagos, porque necesitamos que quede
    # asentada la plata que nos dan en realidad
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

    def caja_es_de_efectivo
      errors.add(:caja, :debe_ser_de_efectivo) unless caja.efectivo?
    end
end
