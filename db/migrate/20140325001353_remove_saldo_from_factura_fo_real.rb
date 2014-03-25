class RemoveSaldoFromFacturaFoReal < ActiveRecord::Migration
  def change
    remove_column :facturas, :saldo_moneda
    remove_column :facturas, :saldo_centavos
  end
end
