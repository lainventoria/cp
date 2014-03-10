# encoding: utf-8
class Caja < ActiveRecord::Base
  belongs_to :obra
  has_many :movimientos

  validates_presence_of :obra_id, :tipo

  # Las cajas son de efectivo o bancarias
  SITUACIONES = %w(efectivo banco)
  validates_inclusion_of :situacion, in: SITUACIONES

  # Garantiza que los nuevos tipos escritos parecido a los viejos se corrijan
  # con los valores viejos
  normalize_attribute :tipo, with: [ :squish, :blank ] do |valor|
    tipos_normalizados = tipos.inject({}) do |hash_de_tipos, tipo|
      hash_de_tipos[tipo.parameterize] = tipo and hash_de_tipos
    end

    if tipos_normalizados.keys.include?(valor.parameterize)
      tipos_normalizados[valor.parameterize]
    else
      valor
    end
  end

  def banco?
    situacion == 'banco'
  end

  def efectivo?
    situacion == 'efectivo'
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

  # El cambio de moneda registra la transacción con un movimiento de salida
  # (negativo) y un movimiento de entrada en la nueva moneda.
  #
  # Este índice de cambio no se registra en el banco default
  def cambiar(cantidad, moneda, indice)
    # Sólo si la caja tiene suficiente saldo devolvemos el monto convertido
    Caja.transaction do
      # Crear un recibo que agrupe todos los movimientos producto de
      # este cambio
      recibo = self.crear_recibo_interno

      extraer(cantidad, true, recibo)
      cantidad.bank.exchange cantidad.fractional, indice do |nuevo|
        depositar(Money.new(nuevo, moneda), true, recibo)
      end
    end || Money.new(0)
  end

  # Sólo si la caja tiene suficiente saldo devolvemos el monto convertido,
  # caso contrario no devolvemos nada, opcionalmente una excepción para frenar
  # la transacción
  def extraer(cantidad, lanzar_excepcion = false, recibo = nil)
    # Se arrastra el recibo si hay
    if cantidad <= total(cantidad.currency.iso_code)
      depositar(cantidad * -1, false, recibo)
      cantidad
    else
      raise ActiveRecord::Rollback, 'Falló la extracción' if lanzar_excepcion
    end
  end

  # Devolvemos cantidad para mantener consistente la API, opcionalmente una
  # excepción para frenar la transacción
  # 
  # Si el tipo de caja es banco, esto se considera una transferencia
  # bancaria
  def depositar(cantidad, lanzar_excepcion = false, recibo = nil)
    # Crear un recibo adhoc para este movimiento
    recibo = crear_recibo_interno unless recibo
    if movimientos.create(monto: cantidad, recibo: recibo)
      cantidad
    else
      raise ActiveRecord::Rollback, 'Falló el depósito' if lanzar_excepcion
    end
  end

  # Crear un recibo interno para una transacción específica
  def crear_recibo_interno
    recibo = Recibo.create(importe: 0,
                           situacion: 'interno',
                           fecha: Time.now)
  end

  def depositar_cheque(cheque)
    cheque.depositar
  end

  def cobrar_cheque(cheque)
    cheque.cobrar
  end

  # emitir un cheque acepta todos los argumentos de un cheque normal y
  # devuelve uno
  def emitir_cheque(*args)
    Cheque.create(*args)
  end

  def pagar_cheque(cheque)
    cheque.pagar
  end

  # transferir un monto de una caja a otra
  def transferir(monto, caja, recibo = nil)
    recibo = crear_recibo_interno if not recibo
    Caja.transaction do
      self.extraer monto, false, recibo
      caja.depositar monto, true, recibo
    end
  end
end
