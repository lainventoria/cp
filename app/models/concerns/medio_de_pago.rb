# encoding: utf-8
# Representa la interfaz que debe proveer un medio de pago para ser usado por
# el sistema
module MedioDePago
  extend ActiveSupport::Concern

  included do
    # Cada medio de pago tiene movimientos, de los cuales es la causa
    has_many :movimientos, as: :causa
  end

  # Cada medio de pago tiene que implementar su propio proceso de pago
  def pagar(recibo)
    raise NotImplementedError, 'Cada medio de pago debe definir `pagar`'
  end
end
