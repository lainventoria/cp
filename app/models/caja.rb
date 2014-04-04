# encoding: utf-8
class Caja < ActiveRecord::Base

  default_scope { where(archivada: false) }

  belongs_to :obra, inverse_of: :cajas
  has_many :movimientos
  has_many :cheques, ->{ where.not(estado: ['cobrado','pagado']) }, foreign_key: 'chequera_id'
  has_many :cheques_en_cuenta, foreign_key: 'cuenta_id', class_name: 'Cheque'
  has_many :retenciones, foreign_key: 'chequera_id'
  has_many :retenciones_a_pagar, foreign_key: 'cuenta_id', class_name: 'Retencion'

  validates_presence_of :obra_id, :tipo
  validates_uniqueness_of :tipo, scope: [:obra_id, :numero]

  # Las cajas son de efectivo, bancarias o chequeras
  SITUACIONES = %w(efectivo banco chequera)
  validates_inclusion_of :situacion, in: SITUACIONES

  # Garantiza que los nuevos tipos escritos parecido a los viejos se corrijan
  # con los valores viejos
  normalize_attribute :tipo, with: [ :squish, :blank ] do |valor|
    tipos_normalizados = tipos.inject({}) do |hash_de_tipos, tipo|
      hash_de_tipos[tipo.parameterize] = tipo and hash_de_tipos
    end

    if valor.present?
      if tipos_normalizados.keys.include?(valor.parameterize)
        tipos_normalizados[valor.parameterize]
      else
        valor
      end
    end
  end

  scope :cuentas, ->{ where(situacion: 'banco') }
  scope :chequeras, ->{ where(situacion: 'chequera') }
  scope :de_efectivo, ->{ where(situacion: 'efectivo') }

  def self.con_fondos_en(moneda)
    joins(:movimientos).where('movimientos.monto_moneda = ?', moneda)
  end

  def banco?
    situacion == 'banco'
  end
  alias_method :cuenta?, :banco?

  def efectivo?
    situacion == 'efectivo'
  end

  def chequera?
    situacion == 'chequera'
  end

  def self.tipos
    pluck(:tipo).uniq
  end

  # Traer todas las monedas usadas
  def monedas
    movimientos.pluck(:monto_moneda).uniq
  end

  # TODO ver si hace falta un caso especial con movimientos sin guardar
  def total(moneda = 'ARS')
    Money.new(movimientos.where(monto_moneda: moneda).sum(:monto_centavos), moneda)
  end

  def totales
    if movimientos.empty?
      { 'ARS' => Money.new(0) }
    else
      movimientos.pluck(:monto_moneda).uniq.inject({}) do |hash, moneda|
        hash[moneda] = total(moneda)
        hash
      end
    end
  end

  # Te doy 3 pesos por tus 100 dólares
  def cambiar(cantidad, cantidad_aceptada)
    Caja.transaction do
      recibo = Recibo.interno_nuevo
      salida = extraer(cantidad, true)
      entrada = depositar(cantidad_aceptada, true)
      salida.causa = entrada.causa = Operacion.new
      recibo.movimientos << salida << entrada
      recibo
    end
  end

  # transferir un monto de una caja a otra
  def transferir(monto, caja)
    Caja.transaction do
      recibo = Recibo.interno_nuevo
      salida = extraer(monto, true)
      entrada = caja.depositar(monto, true)
      salida.causa = entrada.causa = Operacion.new
      recibo.movimientos << salida << entrada
      recibo
    end
  end

  # Sólo si la caja tiene suficiente saldo o es una chequera, devolvemos el
  # movimiento realizado, caso contrario no devolvemos nada, opcionalmente una
  # excepción para frenar la transacción
  def extraer(cantidad, lanzar_excepcion = false)
    if cantidad.positive? &&
      (cantidad <= total(cantidad.currency.iso_code) || chequera?)
      depositar(cantidad * -1, false)
    else
      raise ActiveRecord::Rollback, 'Falló la extracción' if lanzar_excepcion
      invalido = movimientos.build monto: Money.new(0)
      invalido.errors.add(:monto, :no_hay_fondos_suficientes)
      invalido
    end
  end

  # Carga una extracción en esta caja respaldada con un recibo interno
  def extraer!(cantidad)
    Caja.transaction do
      recibo = Recibo.interno_nuevo
      # FIXME agregar causa al movimiento
      recibo.movimientos << extraer(cantidad, true)
      recibo
    end
  end

  # Devolvemos el movimiento realizado, u opcionalmente una excepción para
  # frenar la transacción.
  #
  # Si el tipo de caja es banco, esto se considera una transferencia
  # bancaria
  def depositar(cantidad, lanzar_excepcion = false)
    if movimiento = movimientos.build(monto: cantidad)
      movimiento
    else
      raise ActiveRecord::Rollback, 'Falló el depósito' if lanzar_excepcion
    end
  end

  # Carga un depósito en esta caja respaldado con un recibo interno
  def depositar!(cantidad)
    Caja.transaction do
      recibo = Recibo.interno_nuevo
      # FIXME agregar causa al movimiento
      recibo.movimientos << depositar(cantidad, true)
      recibo
    end
  end

  # TODO revisar necesidad
  def depositar_cheque(cheque)
    cheque.depositar self
  end

  # TODO revisar necesidad
  def cobrar_cheque(cheque)
    cheque.cobrar
  end

  # Devuelve un cheque nuevo que puede usarse para pagar algún recibo.
  # Recién cuando se usa se extrae el monto de la chequera. Recién cuando se
  # paga se extrae el monto de la cuenta y se salda la chequera
  # TODO validar que self sea una cuenta
  # TODO validar parametros?
  def emitir_cheque(parametros = {})
    # Siempre emitimos desde la chequera de la obra
    parametros.merge!(chequera: obra.chequera_propia)
    # y cuando corresponda sacaremos el monto de esta cuenta
    cheques_en_cuenta.propios.create parametros
  end

  # TODO revisar necesidad. puede ser que complete el ciclo de movimientos pero
  # mejor haría un 'pagar_todo'
  def pagar_cheque(cheque)
    cheque.pagar
  end

  # las cajas no se pueden destruir, solo se marcan como archivadas 
  def archivar
    totales.each do |total|
      if total[1] > 0
        errors.add :base, :no_archivar_con_saldo
        return nil
      end
    end

    self.archivada = true
    save
  end

  def descripcion
    "#{efectivo? ? 'Caja' : banco} - #{tipo}"
  end
end
