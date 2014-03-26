# encoding: utf-8
class Movimiento < ActiveRecord::Base
  belongs_to :caja
  belongs_to :recibo, inverse_of: :movimientos
  # Tiene asociada una causa, que lo justifica/respalda. Por causa nos referimos a:
  # - en el caso de efectivo, a los billetes que cambian de manos identificados
  #   por su nro. de serie
  # - en el caso de transferencias, al certificado del banco que la respalda
  #   (id de transferencia)
  # - en el caso de cheque propio o de terceros, el id del cheque y la
  #   informacion que este contiene
  # - en el caso de una retención, al PDF emitido por el contador que se le
  #   entrega al cliente al pagar
  belongs_to :causa, polymorphic: true

  monetize :monto_centavos, with_model_currency: :monto_moneda

  # TODO exigir causa
  validates_presence_of :caja, :recibo, :monto
end
