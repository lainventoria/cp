class TercerosCambiosAFacturas < ActiveRecord::Migration

  def up
    remove_column :facturas, :nombre
    remove_column :facturas, :cuit
    remove_column :facturas, :domicilio
    add_reference :facturas, :tercero, index: true
  end

  def down
    add_column :facturas, :nombre, :text 
    add_column :facturas, :cuit, :text
    add_column :facturas, :domicilio, :text
    remove_column :facturas, :tercero
  end

end
