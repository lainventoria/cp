class AddTipoFacturaToCaja < ActiveRecord::Migration
  def change
    add_column :cajas, :tipo_factura, :string
  end
end
