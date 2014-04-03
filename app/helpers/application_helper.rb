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
    number_to_currency(numero, delimiter: ".", separator: ",", format: '%n .', negative_format: '( %n )' )
  end

  def negativo_rojo(monto)
    monto < 0 ? 'text-danger' : ''
  end

  # decidir si vamos a incluir /obra/:obra_id en las urls o no, para
  # filtrar por obra
  def con_obra?(url)
    # los /obra/new tienen una obra que todavía no existe seteada
    if @obra.try :persisted?
      obra_path(@obra) + url
    else
      url
    end
  end

  # generar saltos entre obras desde la url actual
  # TODO cleverizar
  def con_esta_obra(obra = nil)
    # somos especificos con el controlador
    case params[:controller]
      when 'obras' then
        if obra
          # si la obra esta seteada, queremos verla
          url_for(params.merge({ action: 'show', id: obra.try(:id) }))
        else
          # sino, queremos ver el indice
          url_for(params.merge({ action: 'index', id: nil }))
        end
      when 'facturas' then
        case params[:action]
          # las facturas de cobros y pagos llevan al mismo listado en
          # otra obra
          when 'pagos' then url_for(params.merge({ obra_id: obra.try(:id) }))
          when 'cobros' then url_for(params.merge({ obra_id: obra.try(:id) }))
          # pero el resto lleva al listado de cobros o pagos segun que
          # factura estemos viendo
          else url_for(params.merge({ obra_id: obra.try(:id), action: @factura.try(:situacion) +"s", id: nil }))
        end
      when 'recibos' then
        case params[:action]
          # los recibos de cobros y pagos llevan al mismo listado en
          # otra obra
          when 'pagos' then url_for(params.merge({ obra_id: obra.try(:id), factura_id: nil }))
          when 'cobros' then url_for(params.merge({ obra_id: obra.try(:id), factura_id: nil }))
          # para las otras acciones vamos al listado segun la situacion
          # del recibo actual
          else url_for(params.merge({ obra_id: obra.try(:id), factura_id: nil, action: @recibo.try(:situacion) +"s", id: nil }))
        end
      # para las cajas siempre queremos ir al indice de cajas segun obra
      when 'cajas' then url_for(params.merge({ obra_id: obra.try(:id), action: 'index', id: nil }))
      # para los cheques siempre queremos ir al indice de cheques segun
      # obra, que es el minimo comun denominador entre obras (las cajas
      # cambian!)
      when 'cheques' then url_for(params.merge({ obra_id: obra.try(:id), caja_id: nil, action: 'index', id: nil }))
      # las retenciones siempre llevan a su indice segun obra
      when 'retenciones' then url_for(params.merge({ obra_id: obra.try(:id), factura_id: nil, action: 'index', id: nil }))
      # los terceros no se filtran por obra
      when 'terceros' then url_for(params.merge({ obra_id: nil }))
      # para cualquier otra cosa, imitar con_obra?
      else url_for(params.merge({ obra_id: obra.try(:id) }))
    end
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
