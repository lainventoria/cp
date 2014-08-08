module FacturasHelper

  def titulo_lista_facturas
    if @situacion == 'pago'
      'Listado de Facturas por Pagar'
    else
      'Listado de Facturas por Cobrar'
    end
  end

  def titulo_detalle_factura
    if @factura.pago?
      'Factura por Pagar'
    else
      'Factura por Cobrar'
    end
  end

  def facturas_por_tipo_path
    if determina_situacion_factura == 'pago'
      pagos_facturas_path
    else
      cobros_facturas_path
    end
  end

  def determina_situacion_factura
    if @factura.new_record?
      params[:situacion]
    else
      @factura.situacion
    end
  end

  def moneda_factura
    if @factura.new_record?
      'ARS'
    else
      @factura.importe_neto_moneda
    end
  end

  def obra_factura
    @factura.new_record? ? params[:obra_id] : @factura.obra_id
  end

  def url_for_saldadas
    if params[:saldadas].present?
      url_for(saldadas: nil)
    else
      url_for(saldadas: true)
    end
  end

  def titulo_para_saldadas
    if params[:saldadas].present?
      'Ver por saldar'
    else
      'Ver saldadas'
    end
  end
end
