json.array!(@terceros) do |tercero|
  json.extract! tercero, :id, :nombre, :direccion, :telefono, :celular, :email, :iva, :proveedor, :cliente, :cuit
  json.url tercero_url(tercero, format: :json)
end
