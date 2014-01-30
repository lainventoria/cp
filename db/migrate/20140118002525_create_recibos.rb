class CreateRecibos < ActiveRecord::Migration
  def change
    create_table :recibos do |t|
      t.timestamp :fecha
      t.money :importe
      t.boolean :emitido
      t.boolean :recibido
      t.belongs_to :factura, index: true

      t.timestamps
    end
  end
end
