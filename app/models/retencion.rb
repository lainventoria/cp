# encoding: utf-8
class Retencion < ActiveRecord::Base
  # La factura sobre la que se hace la retención
  belongs_to :factura

  # El recibo del pago de otra factura
  belongs_to :recibo
  has_one :factura_pagada, through: :recibo

  # TODO sólo pdfs?
  has_attached_file :documento
  validates_attachment_content_type :documento, content_type: /\Aapplication\/pdf\Z/

  monetize :monto_centavos, with_model_currency: :monto_moneda
end