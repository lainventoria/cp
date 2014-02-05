class Caja < ActiveRecord::Base
  belongs_to :obra
  has_many :movimientos

  validates_presence_of :obra_id, :tipo

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
    if cantidad <= total(cantidad.currency.iso_code)
      cantidad.bank.exchange cantidad.fractional, indice do |nuevo|
        movimientos.create monto: cantidad * -1
        movimientos.create monto: Money.new(nuevo, moneda)
      end.monto
    else
      Money.new(0)
    end
  end

  def self.tipos
    pluck(:tipo).uniq
  end
end
