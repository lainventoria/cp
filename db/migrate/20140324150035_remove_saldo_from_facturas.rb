class RemoveSaldoFromFacturas < ActiveRecord::Migration
  def change
    remove_column :facturas, :saldo
  end
end
