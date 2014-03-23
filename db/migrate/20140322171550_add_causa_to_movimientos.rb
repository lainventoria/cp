class AddCausaToMovimientos < ActiveRecord::Migration
  def change
    add_reference :movimientos, :causa, polymorphic: true, index: true
  end
end
