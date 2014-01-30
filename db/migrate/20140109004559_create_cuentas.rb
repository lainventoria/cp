class CreateCuentas < ActiveRecord::Migration
  def change
    create_table :cuentas do |t|
      t.string :numero
      t.integer :obra_id

      t.timestamps
    end
  end
end
