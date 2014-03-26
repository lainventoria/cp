class CambiarCajaPorCuentaEnCheques < ActiveRecord::Migration
  def change
    rename_column :cheques, :caja_id, :cuenta_id
  end
end
