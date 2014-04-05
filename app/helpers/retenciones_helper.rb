module RetencionesHelper
  def situaciones_para_select
    [ [ 'Impuesto a las Ganancias', 'ganancias' ],
      [ 'Cargas Sociales', 'cargas_sociales' ] ]
  end

  def tipo_de_retencion(tipo)
    tipo == 'ganancias' ? 'Ganancias' : 'CC.Sociales'
  end
end
