class AddDefaultEnSituaciones < ActiveRecord::Migration
  def up
    change_column :recibos, :situacion, :string, default: 'pago'
    change_column :facturas, :situacion, :string, default: 'pago'
  end

  def down
    change_column :recibos, :situacion, :string, default: nil
    change_column :facturas, :situacion, :string, default: nil
  end
end
