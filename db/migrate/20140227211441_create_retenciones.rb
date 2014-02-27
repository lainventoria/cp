class CreateRetenciones < ActiveRecord::Migration
  def change
    create_table :retenciones do |t|
      t.references :factura, index: true
      t.references :recibo, index: true

      t.timestamps
    end

    add_money :retenciones, :monto
  end
end
