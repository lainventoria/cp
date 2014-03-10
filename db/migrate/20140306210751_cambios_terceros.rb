class CambiosTerceros < ActiveRecord::Migration

  def up
    remove_column :terceros, :proveedor
    remove_column :terceros, :cliente
    add_column :terceros, :relacion, :string

    add_column :terceros, :contacto, :string
    add_column :terceros, :notas, :text
  end

  def down
    add_column :terceros, :proveedor, :boolean
    add_column :terceros, :cliente, :boolean
    remove_column :terceros, :relacion

    remove_column :terceros, :contacto
    remove_column :terceros, :notas
  end

end
