module RecibosHelper
  def recibos_por_tipo_path
    if determina_situacion_recibo == 'pago'
      pagos_recibos_path
    else
      cobros_recibos_path
    end
  end

  # TODO ver si delegar la situación a la factura
  def determina_situacion_recibo
    if @recibo.new_record?
      @factura.situacion
    else
      @recibo.situacion
    end
  end

  def link_a_causa(movimiento)
    case movimiento.causa_type
      # Las causas sin vista en el sistema no generan links
      when 'Efectivo', 'Transferencia', 'Operacion'
        movimiento.causa_type
      else
        # TODO sacar el if cuando todos los movimientos tengan causa
        link_to(movimiento.causa_type, movimiento.causa) if movimiento.causa.present?
    end
  end

  def link_a_nuevo_movimiento(causa)
    link_to causa,
      new_factura_movimiento_path(@recibo.factura, causa_tipo: causa.parameterize),
      data: { remote: true }, class: 'agregar-movimiento'
  end

  def cheques_de_terceros
    @factura.obra.cheques.de_terceros.order(:fecha_vencimiento)
  end

  def retenciones
    @factura.retenciones
  end

  # TODO si la caja no tiene fondos no sale ninguna
  def cajas_de_efectivo
    @factura.obra.cajas.de_efectivo.
      where(tipo_factura: (@factura.tipo == 'X' ? 'X' : nil)).
      con_fondos_en(@factura.importe_total_moneda).uniq
  end

  def cuentas
    @factura.obra.cajas.cuentas
  end
end
