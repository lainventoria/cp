module RecibosHelper
  def recibos_por_tipo_path
    if determina_situacion_recibo == 'pago'
      pagos_recibos_path
    else
      cobros_recibos_path
    end
  end

  def determina_situacion_recibo
    if @recibo.new_record?
      @factura.situacion
    else
      @recibo.situacion
    end
  end

  def link_a_causa(movimiento)
    case movimiento.causa_type
      when 'Efectivo', 'Transferencia'
        movimiento.causa_type
      else
        # TODO sacar el if cuando todos los movimientos tengan causa
        link_to(movimiento.causa_type, movimiento.causa) if movimiento.causa.present?
    end
  end

  def link_a_nuevo_movimiento(causa)
    link_to causa,
      new_factura_causa_path(@recibo.factura, causa_tipo: causa.parameterize, obra_id: @recibo.obra),
      data: { remote: true }, class: 'agregar-movimiento'
  end
end
