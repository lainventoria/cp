module ApplicationHelper
  # Título de la página para el +<head>+ por defecto
  def titulo_de_la_aplicacion
    "#{titulo.present? ? "#{titulo} | " : nil}CP"
  end

  # Por defecto, no se usa nada. Cada helper específico redefine este método si
  # quiere un título específico
  def titulo
    nil
  end

	def formatted_date(date)
    date.nil? ? '' : date.strftime("%d %b %Y")
	end

  # seguramente hay una forma más elegante de hacer esto...
  def validar_cuit(cuit)
    # convertir a string si se pasa un número, remover los guiones si
    # era una cadena
    cuit_sin_validar = cuit.to_s.gsub /[^0-9]/, ''

    # parece que el cuit es siempre de 11 cifras
    return nil if not cuit_sin_validar.length == 11

    multiplicadores = [ 5, 4, 3, 2, 7, 6, 5, 4, 3, 2, 1 ]
    resultado = 0

    # multiplica cada elemento del cuit por uno de los multiplicadores
    for i in 0..10
      resultado = resultado + cuit_sin_validar[i].to_i * multiplicadores[i]
    end

    # el cuit es valido si el resto de dividir el resultado por 11 es 0
    (resultado % 11) == 0
  end

  # habilita la edicion de los formularios segun el valor de @editar
  def editar_o_bloquear
    if ! @editar
      'disabled'
    end
  end

  def formatted_number(numero)
    number_with_delimiter(numero, delimiter: ".", separator: ",")
  end

  # decidir si vamos a incluir /obra/:obra_id en las urls o no, para
  # filtrar por obra
  def con_obra?(url)
    # los /obra/new tienen una obra que todavía no existe seteada
    if @obra and not @obra.new_record?
      obra_path(@obra) + url
    else
      url
    end
  end

  # genera un link a la url actual en otra obra (o al listado
  # correspondiente en otra obra)
  def link_to_obra(obra = nil)
    extra_params = {}
    nombre = obra ? obra.nombre : 'Todas las Obras'

    if not obra
      extra_params.merge!({obra_id: nil})
    elsif params[:controller] == 'obras'
      extra_params.merge!({id: obra.id, action: 'show'})
    elsif params[:action] == 'show'
      # al dessetear el id se corrige el ?id=X flotante
      extra_params.merge!({obra_id: obra.id, id: nil, action: 'index'})
    else
      extra_params.merge!({obra_id: obra.id})
    end

    # capoooo -- correccion: usa situacion solo cuando se vuelve a un
    # listado de facturas/recibos, desde una vista de ese controlador
    if params[:controller] == 'facturas' && ( params[:action] != 'pagos' && params[:action] != 'cobros' )
      extra_params.merge!({action: @factura.situacion + 's', id: nil}) if ! @factura.new_record?
    end

    if params[:controller] == 'recibos' && ( params[:action] != 'pagos' && params[:action] != 'cobros' )
      extra_params.merge!({action: @recibo.situacion + 's', factura_id: nil, id: nil}) if ! @recibo.new_record?
    end

    link_to nombre, url_for(params.merge(extra_params))
  end

  def alert_range(num)
    if num == 0
      'info'
    elsif num > 0
      'success'
    elsif num < 0
      'danger'
    end
  end
end
