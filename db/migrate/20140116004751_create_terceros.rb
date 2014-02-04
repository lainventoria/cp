class CreateTerceros < ActiveRecord::Migration
  def change
    create_table :terceros do |t|
      t.string :nombre
      t.text :direccions
      t.text :telefono
      t.text :celular
      t.string :email
      t.float :iva
      t.binary :proveedor
      t.binary :cliente
      t.string :cuit

      t.timestamps
    end
  end
end
