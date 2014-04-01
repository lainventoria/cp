# encoding: utf-8
class Obra < ActiveRecord::Base
  has_many :cajas, ->{ where(archivada: false) }, dependent: :restrict_with_error
  has_many :cheques, through: :cajas
  has_many :facturas, dependent: :restrict_with_error
  has_many :recibos, through: :facturas
  has_many :retenciones, through: :facturas


  has_one :chequera_propia, ->{ where(tipo: 'Chequera propia').where(archivada: false) },
    class_name: 'Caja'
  has_one :caja_afip, ->{ where(tipo: 'Caja AFIP') },
    class_name: 'Caja'

  after_create :crear_cajas

  validates_presence_of :nombre, :direccion

  # Sumar los saldos de todas las facturas según situación
  def saldo_de(pago_o_cobro, moneda = 'ARS')
    saldo = Money.new(0, moneda)

    facturas.where(situacion: pago_o_cobro).
             where(importe_total_moneda: moneda).
             find_each do |factura|
      saldo += factura.saldo
    end

    saldo
  end

  # los pagos son salidas
  # TODO si pasamos a registrar los movimientos de pago como movimientos
  # negativos hay que cambiar acá
  def saldo_de_pago(moneda = 'ARS')
    saldo_de('pago', moneda) * -1
  end

  def saldo_de_cobro(moneda = 'ARS')
    saldo_de 'cobro', moneda
  end

  # positivo + negativo es lo mismo que positivo - positivo :P
  def saldo_general(moneda = 'ARS')
    saldo_de_cobro(moneda) + saldo_de_pago(moneda)
  end

  # devuelve el total de todas las cajas para una moneda
  def total_general(moneda = 'ARS', parametros = {})
    total = Money.new(0, moneda)
    cajas.where(parametros).find_each do |caja|
      total += caja.total(moneda)
    end

    total
  end

  private

    def crear_cajas
      ['Obra', 'Administración', 'Seguridad'].each do |tipo|
        cajas.create tipo: tipo, situacion: 'efectivo'
      end

      cajas.create tipo: 'Caja de Ahorro', situacion: 'banco'
      cajas.create tipo: 'Chequera', situacion: 'chequera'
      cajas.create tipo: 'Chequera propia', situacion: 'chequera'
      cajas.create tipo: 'Caja AFIP', situacion: 'chequera'
    end
end
