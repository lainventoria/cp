class EliminarBooleans < ActiveRecord::Migration
  def up
    remove_column :recibos, :emitido
    remove_column :recibos, :recibido

    remove_column :facturas, :recibida
    remove_column :facturas, :emitida

    add_column :facturas, :emitida_o_recibida, :string
    add_column :recibos, :emitido_o_recibido, :string
  end

  def down
    add_column :recibos, :emitido, :boolean
    add_column :recibos, :recibido, :boolean

    add_column :facturas, :recibida, :boolean
    add_column :facturas, :emitida, :boolean

    remove_column :facturas, :emitida_o_recibida
    remove_column :recibos, :emitido_o_recibido
  end
end
