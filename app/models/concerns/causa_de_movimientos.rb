# encoding: utf-8
# La interfaz que debe proveer cualquier objeto que sirva como causa de un
# movimiento en el sistema. Se define la asociación con los movimientos y la
# destrucción de movimientos asociados si eliminamos la causa. Además, cada
# causa que sirva como medio de pago tiene que implementar su propio proceso de
# pago en
#
#     usar_para_pagar(recibo)
#
# devolviendo el movimiento de extracción realizado.
#
# Cada causa que sirva como medio de cobro tiene que implementar su propio
# proceso de cobro en
#
#     usar_para_cobrar(recibo)
#
# devolviendo el movimiento de depósito realizado.
#
# Por último, cada causa debe saber cómo construirse en base a los parámetros
# de inicialización, mediante el método de clase
#
#     construir(params)
#
# Ejemplos
#
#   e = Efectivo.construir monto: Money.new(100), caja_id: 1
#   # => #<Efectivo:0x00000007394520>
#
#   e.usar_para_pagar recibo
#   # => #<Movimiento:0x000000072288f8>
#
#   e.usar_para_cobrar recibo
#   # => #<Movimiento:0x00000007558ca8>
module CausaDeMovimientos
  extend ActiveSupport::Concern

  included do
    # Cada medio de pago tiene movimientos, de los cuales es la causa
    has_many :movimientos, as: :causa

    before_destroy :destruir_movimientos
  end

  # Destruye todos los movimientos asociados con esta causa, salteando el
  # callback en Movimiento que impide su destrucción si su causa es trackeable
  #
  # Devuelve nada.
  def destruir_movimientos
    # `delete` saltea los callbacks
    movimientos.each &:delete
  end
end
