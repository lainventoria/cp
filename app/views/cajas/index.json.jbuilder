json.array!(@cajas) do |caja|
  json.extract! caja, :id, :obra_id
  json.url obra_caja_url(obra, caja, format: :json)
end
