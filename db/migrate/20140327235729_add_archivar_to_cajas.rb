class AddArchivarToCajas < ActiveRecord::Migration
  def change
    add_column :cajas, :archivada, :boolean

    reversible do |dir|
      dir.up {
        Caja.update_all archivada: false
      }
    end

  end
end
