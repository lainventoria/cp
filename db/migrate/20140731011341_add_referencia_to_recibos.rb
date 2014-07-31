class AddReferenciaToRecibos < ActiveRecord::Migration
  def change
    add_reference :recibos, :recibo, index: true
  end
end
