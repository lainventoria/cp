class AddDestinoToCheques < ActiveRecord::Migration
  def change
    add_reference :cheques, :destino, index: true
  end
end
