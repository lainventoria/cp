json.array!(@facturas) do |factura|
  json.extract! factura, :id, :tipo, :numero, :emitida, :recibida, :nombre, :domicilio, :cuit, :iva, :descripcion, :importe_total, :fecha, :fecha_pago
  json.url factura_url(factura, format: :json)
end
