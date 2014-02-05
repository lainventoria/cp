class AddTipoToCaja < ActiveRecord::Migration
  def change
    add_column :cajas, :tipo, :string, null: false, default: 'De obra'
  end
end
