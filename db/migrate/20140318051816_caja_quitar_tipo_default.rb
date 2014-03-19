class CajaQuitarTipoDefault < ActiveRecord::Migration

  # TODO ver como evitar perder los tipos existentes al borrar la
  # antigua columna tipo y traspasarlos a la nueva columna tipo

  def change
    change_column_default :cajas, :tipo, nil
  end

end
