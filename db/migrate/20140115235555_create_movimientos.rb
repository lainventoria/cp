class CreateMovimientos < ActiveRecord::Migration
  def change
    create_table :movimientos do |t|
      t.integer :caja_id
      t.money :monto

      t.timestamps
    end
  end
end
