class ChangeClienteFromTerceros < ActiveRecord::Migration
  def change
    change_column :terceros, :cliente, :boolean
  end
end
