class ChangeProveedorFromTerceros < ActiveRecord::Migration
  def change
    change_column :terceros, :proveedor, :boolean
  end
end
