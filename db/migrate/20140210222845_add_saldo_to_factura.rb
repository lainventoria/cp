class AddSaldoToFactura < ActiveRecord::Migration
  def change
    add_money :facturas, :saldo
  end
end
