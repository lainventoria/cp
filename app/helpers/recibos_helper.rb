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

    cajas = @factura.obra.cajas.de_efectivo.
      where(tipo_factura: tipos)

    if @factura.pago?
      cajas.con_fondos_en(@factura.importe_total_moneda).uniq
    else
      cajas.uniq
    end
  end

  def cuentas_de_donde_transferir
    cuentas = @factura.obra.cajas.cuentas

    if @factura.pago?
      cuentas.con_fondos_en(@factura.importe_total_moneda)
    else
      cuentas
    end
  end

  def cuentas_de_donde_emitir
    @factura.obra.cajas.cuentas
  end

  def chequeras_para_cheques_de_terceros
    tipos = @factura.tipo_valido? ? Cp::Application.config.tipos_validos : Factura.tipos_invalidos

    if @factura.tipo_valido?
      [ @factura.obra.chequera ]
    else
      @factura.obra.cajas.chequeras.
        where(tipo_factura: Factura.tipos_invalidos)
    end
  end
end
