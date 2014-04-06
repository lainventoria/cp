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

  # crea un listado de cheques segun el tipo de factura que aceptan sus
  # cajas
  def cheques_de_terceros
    @factura.obra.cheques.de_terceros.order(:fecha_vencimiento).reject do |c|
      # si la factura es valida, rebota las cajas de tipo invalido
      # si la factura es invalida, rebota las cajas de tipo valido
      if @factura.tipo_valido?
        c.chequera.factura_invalida?
      else
        c.chequera.factura_valida?
      end
    end
  end

  def retenciones
    @factura.retenciones
  end

  # TODO si la caja no tiene fondos no sale ninguna
  def cajas_de_efectivo
    tipos = @factura.tipo_valido? ? Cp::Application.config.tipos_validos : Factura.tipos_invalidos

    @factura.obra.cajas.de_efectivo.
      where(tipo_factura: tipos).
      con_fondos_en(@factura.importe_total_moneda).uniq
  end

  def cuentas_de_donde_transferir
    @factura.obra.cajas.cuentas.con_fondos_en(@factura.importe_total_moneda)
  end

  def cuentas_de_donde_emitir
    @factura.obra.cajas.cuentas
  end

  def establecer_parametros_listado
    case params[:controller]
      when 'recibos'
        lista_larga = ''
        lista_causa = 'hidden'
        muestra_importe = ''
      when 'facturas'
        lista_larga = 'hidden'
        lista_causa = 'hidden'
        muestra_importe = ''
      # por eliminacion, esto es para las causas que listan recibos  
      else
        lista_larga = 'hidden'
        lista_causa = ''
        muestra_importe = 'hidden'
    end
    return [ lista_larga, lista_causa, muestra_importe ]
  end
end
