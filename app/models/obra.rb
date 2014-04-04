# encoding: utf-8
class Obra < ActiveRecord::Base
  has_many :cajas, ->{ where(archivada: false) }, dependent: :restrict_with_error
  has_many :cheques, through: :cajas
  has_many :facturas, dependent: :restrict_with_error
  has_many :recibos, through: :facturas
  has_many :retenciones, through: :facturas

  # TODO mejorar esta cosa
  has_one :chequera_propia, ->{ where(tipo: 'Chequera propia').where(archivada: false) },
    class_name: 'Caja'
  has_one :chequera, ->{ where(tipo: 'Chequera') },
    class_name: 'Caja'
  has_one :caja_ganancias, ->{ where(tipo: 'Retenciones de Ganancias') },
    class_name: 'Caja'
  has_one :caja_cargas_sociales, ->{ where(tipo: 'Retenciones de Cargas Sociales') },
    class_name: 'Caja'

  after_create :crear_cajas

  validates_presence_of :nombre, :direccion

  # Abstracción para traer totales de facturas, se le pasa el atributo
  # que lleva el monto (importe_total, iva, importe_neto) como string,
  # la moneda y parámetros extra para filtrar.
  #
  # Luego obtiene los centavos y la moneda y devuelve un resultado
  def total_facturas(campo_monto, moneda = 'ARS', params = {})
    total = Money.new(0, moneda)

    # traer solo monto_centavos, monto_moneda y situacion
    facturas.where(params.merge({ :"#{campo_monto}_moneda" => moneda })).
             pluck(:"#{campo_monto}_centavos", :"#{campo_monto}_moneda", :situacion).
             each do |monto|

      # todo se suma, luego se decide si mostrar los pagos como
      # negativos en la interfaz, etc.
      total += Money.new(monto[0], monto[1])

    end

    total
  end

  # calcular el total de iva
  def total_iva(params = { })
    total_facturas('iva', 'ARS', params.merge({ situacion: 'cobro' })) -
    total_facturas('iva', 'ARS', params.merge({ situacion: 'pago' }))
  end

  def saldo_de_facturas(moneda = 'ARS', params = {})
    saldo = Money.new(0, moneda)
    # filtrar todas las de la moneda especificada si o si
    facturas.where(params.merge({ importe_total_moneda: moneda })).find_each do |f|
      saldo += f.saldo
    end

    saldo
  end

  # Sumar los saldos de todas las facturas según situación
  def saldo_de(pago_o_cobro, moneda = 'ARS')
    saldo_de_facturas(moneda, { situacion: pago_o_cobro })
  end

  # los pagos son salidas
  def saldo_de_pago(moneda = 'ARS')
    saldo_de('pago', moneda)
  end

  def saldo_de_cobro(moneda = 'ARS')
    saldo_de 'cobro', moneda
  end

  def saldo_general(moneda = 'ARS')
    saldo_de_cobro(moneda) - saldo_de_pago(moneda)
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

      # Estas cajas solo aceptan factura de tipo X
      cajas.create tipo: 'Administración X', situacion: 'efectivo', tipo_factura: 'X'
      cajas.create tipo: 'Chequera X', situacion: 'chequera', tipo_factura: 'X'

      cajas.create tipo: 'Caja de Ahorro', situacion: 'banco'
      cajas.create tipo: 'Chequera', situacion: 'chequera'
      cajas.create tipo: 'Chequera propia', situacion: 'chequera'
      cajas.create tipo: 'Retenciones de Ganancias', situacion: 'chequera'
      cajas.create tipo: 'Retenciones de Cargas Sociales', situacion: 'chequera'
    end
end
