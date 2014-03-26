class AddChequeraToCheques < ActiveRecord::Migration
  def change
    add_reference :cheques, :chequera, index: true
  end
end
