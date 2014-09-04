# encoding: utf-8
require './test/test_helper'

feature 'Recibos' do
  feature 'Borrar' do
    background do
      @recibo = create :recibo
    end

    scenario 'Esta el boton' do
      visit edit_factura_recibo_path(@recibo.factura, @recibo)
      page.must_have_content 'Editar Recibo'
      page.must_have_link 'Borrar Recibo', href: factura_recibos_path(@recibo.factura)
    end

    scenario 'Un pago efectivo' do
      @recibo.pagar_con efectivo_por(Money.new(100))
      @recibo.save

      visit edit_factura_recibo_path(@recibo.factura, @recibo)
      page.must_have_link 'Efectivo',
        href: obra_caja_path(@recibo.movimientos.last.caja.obra, @recibo.movimientos.last.caja)

      find('a.btn.btn-danger[data-method=delete]').click

      page.must_have_content 'Factura por Pagar'
    end
  end
end
