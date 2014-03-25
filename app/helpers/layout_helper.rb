module LayoutHelper

  # Selecciona la moneda existente en el selector de monedas
  def moneda_seleccionada(moneda1, moneda2)
    moneda1 == moneda2 ? 'selected' : ''
  end
end
