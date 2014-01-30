json.array!(@cajas) do |caja|
  json.extract! caja, :id, :obra_id
  json.url caja_url(caja, format: :json)
end
