Cp::Application.configure do
  # Tipos de factura que son considerados válidos
  #
  # Dejamos nil porque todavía no estamos guardando todos los tipos en
  # las Cajas
  config.tipos_validos = [ nil, 'A', 'B', 'C' ]
end
