module MovimientosHelper

  def establecer_parametros_listado_movimientos(movimientos)
    # ajusta las columnas segun donde se muestre el listado
    case params[:controller]
      when 'cajas'
        lista_cajas = ''
        lista_recibos = 'hidden'
      when 'recibos'
        lista_cajas = 'hidden'
        lista_recibos = ''
      else
        lista_cajas = 'hidden'
        lista_recibos = 'hidden'
    end

    # muestra boton para borrar movimientos si se esta editando el recibo
    if params[:action] == 'edit'
        boton_borrar = ''
      else
        boton_borrar = 'hidden'
    end

    # solo los listados de efectivo tienen mas de una moneda
    if movimientos.pluck(:monto_moneda).uniq.count > 1
        lista_efectivo = ''
      else
        lista_efectivo = 'hidden'
    end

    return [ lista_cajas, lista_recibos, boton_borrar, lista_efectivo ]
  end
end
