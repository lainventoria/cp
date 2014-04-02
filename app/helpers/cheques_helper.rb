module ChequesHelper
  def titulo_vista_cheque
    @cheque.propio? ? "Detalles de Cheque Propio" : "Detalles de Cheque de Tercero"
  end

  def titulo_listado_cheques
    titulo = "Listado de Cheques"
    case params[:situacion]
      when 'propio' then titulo += " Propios"
      when 'terceros' then titulo += " de Terceros"
    end

    titulo += " depositados" if params[:depositados]
    # TODO cambiar a fecha seleccionada
    titulo += " vencidos al #{formatted_date(Time.now)}" if params[:vencidos]

    titulo
  end

  def path_a_listado
    @cheque.propio? ? propios_cheques_path : terceros_cheques_path
  end

  def actualiza_situacion
    params[:situacion] ? @cheque.situacion = params[:situacion] : ''
  end
end
