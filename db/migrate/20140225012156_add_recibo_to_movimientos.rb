class AddReciboToMovimientos < ActiveRecord::Migration
  def change
    add_column :movimientos, :recibo_id, :integer
  end
end
