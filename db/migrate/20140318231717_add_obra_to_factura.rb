class AddObraToFactura < ActiveRecord::Migration
  def change
    add_reference :facturas, :obra, index: true
  end
end
