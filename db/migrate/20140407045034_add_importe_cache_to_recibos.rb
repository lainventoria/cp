class AddImporteCacheToRecibos < ActiveRecord::Migration
  def up
    add_money :recibos, :importe_cache 

    reversible do |dir|
      dir.up {
        Recibo.find_each do |r|
          r.importe_cache = r.importe
          r.save
        end
      }
    end
  end

  def down
    remove_money :recibos, :importe_cache
  end
end
