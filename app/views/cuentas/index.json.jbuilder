json.array!(@cuentas) do |cuenta|
  json.extract! cuenta, :id, :numero, :obra_id
  json.url cuenta_url(cuenta, format: :json)
end
