class AddDireccionToObra < ActiveRecord::Migration
  def change
    add_column :obras, :direccion, :string
  end
end
