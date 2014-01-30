class CreateCajas < ActiveRecord::Migration
  def change
    create_table :cajas do |t|
      t.integer :obra_id

      t.timestamps
    end
  end
end
