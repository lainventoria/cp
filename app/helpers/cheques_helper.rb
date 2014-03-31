module ChequesHelper
  def titulo_vista_cheque
    @cheque.propio? ? "Detalles de Cheque Propio" : "Detalles de Cheque de Tercero"
  end

  def titulo_listado_cheques
    @situacion == 'propio' ? "Listado de Cheques Propios" : "Listado de Cheques de Terceros"
  end

  def path_a_listado
    @cheque.propio? ? propios_cheques_path : terceros_cheques_path
  end

  def actualiza_situacion
    params[:situacion] ? @cheque.situacion = params[:situacion] : ''
  end
end
