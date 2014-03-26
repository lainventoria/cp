class SacarReciboDeCheques < ActiveRecord::Migration
  def up
    remove_column :cheques, :recibo_id, :integer
    remove_column :cheques, :destino_id, :integer
  end

  def down
    add_column :cheques, :recibo_id, :integer
    add_column :cheques, :destino_id, :integer
  end
end
