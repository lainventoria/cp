json.array!(@recibos) do |recibo|
  json.extract! recibo, :id, :fecha, :importe, :emitido, :recibido, :factura_id
  json.url recibo_url(recibo, format: :json)
end
