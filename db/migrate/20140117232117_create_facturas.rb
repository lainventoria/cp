class CreateFacturas < ActiveRecord::Migration
  def change
    create_table :facturas do |t|
      t.string :tipo
      t.string :numero
      t.boolean :emitida
      t.boolean :recibida
      t.text :nombre
      t.text :domicilio
      t.text :cuit
      t.float :iva
      t.text :descripcion
      t.money :importe_total
      t.timestamp :fecha
      t.timestamp :fecha_pago

      t.timestamps
    end
  end
end
