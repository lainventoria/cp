class ArchivadasFalsePorDefecto < ActiveRecord::Migration
  def up
    change_column :cajas, :archivada, :boolean, default: false
  end

  def down
    change_column :cajas, :archivada, :boolean, default: nil
  end
end
