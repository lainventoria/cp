# encoding: utf-8
class Retencion < ActiveRecord::Base
  # La factura sobre la que se hace la retención
  belongs_to :factura

  validate :factura_es_un_pago
  # El recibo del pago de otra factura
  belongs_to :recibo
  has_one :factura_pagada, through: :recibo, source: :factura

  # Sólo PDFs
  has_attached_file :documento
  validates_attachment_content_type :documento, content_type: /\Aapplication\/pdf\Z/

  monetize :monto_centavos, with_model_currency: :monto_moneda

  def pagar(factura)
    self.recibo = factura.pagar monto
  end

  def pagar!(factura)
    pagar factura
    save
  end

  private

    def factura_es_un_pago
      errors.add :factura, :debe_ser_un_pago unless factura.pago?
    end
end
