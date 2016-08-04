class NormalizarLosCuitsExistentes < ActiveRecord::Migration
  def up
    Tercero.find_each do |t|
      t.update_attribute :cuit, Tercero.normalizar_cuit(t.cuit)
    end
  end

  def down
    # Nada que hacer
  end
end
