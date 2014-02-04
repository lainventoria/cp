class FixDireccion < ActiveRecord::Migration
  def change
    rename_column :terceros, :direccions, :direccion
  end
end
