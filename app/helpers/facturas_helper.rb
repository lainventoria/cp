module FacturasHelper

  def titulo_lista_facturas
    if @situacion == 'pago'
      "Listado de Facturas por Pagar"
    else
      "Listado de Facturas por Cobrar"
    end
  end

  def titulo_detalle_factura
    if @factura.pago?
      "Factura por Pagar"
    else
      "Factura por Cobrar"
    end
  end

  def facturas_por_tipo_path
    if @factura.pago?
      pagos_facturas_path
    else
      cobros_facturas_path
    end
  end

  def determina_situacion
    if @factura.new_record?
      params[:situacion] 
    else
      @factura.situacion
    end
  end

  def moneda_factura
    if @factura.new_record?
      "ARS"
    else
      @factura.importe_neto_moneda
    end
  end

  def obra_factura
    @factura.new_record? ? params[:obra_id] : @factura.obra_id
  end
end
