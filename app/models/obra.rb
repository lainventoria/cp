# encoding: utf-8
class Obra < ActiveRecord::Base
  has_many :cajas
  has_many :facturas

  after_create :crear_cajas

  validates_presence_of :nombre, :direccion

  # Sumar los saldos de todas las facturas según situación
  def saldo_de(pago_o_cobro)
    saldo = Money.new(0)

    facturas.where(situacion: pago_o_cobro).find_each do |factura|
      saldo += factura.saldo
    end

    saldo
  end

  # los pagos son salidas
  # TODO si pasamos a registrar los movimientos de pago como movimientos
  # negativos hay que cambiar acá
  def saldo_de_pago
    saldo_de('pago') * -1
  end

  def saldo_de_cobro
    saldo_de 'cobro'
  end

  # positivo + negativo es lo mismo que positivo - positivo :P
  def saldo_general
    saldo_de_cobro + saldo_de_pago
  end

  private

    def crear_cajas
      ['Obra', 'Administración', 'Seguridad'].each do |tipo|
        cajas.create tipo: tipo, situacion: 'efectivo'
      end

      cajas.create tipo: 'Caja de Ahorro', situacion: 'banco'
      cajas.create tipo: 'Chequera', situacion: 'chequera'
    end
end
