class RenombrarListaASituaciones < ActiveRecord::Migration
  def change
    rename_column :facturas, :emitida_o_recibida, :situacion
    rename_column :recibos,  :emitido_o_recibido, :situacion
  end
end
