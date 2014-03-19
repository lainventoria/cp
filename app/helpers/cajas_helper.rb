module CajasHelper

  def valor_situacion
    if @caja.new_record? 
      params[:situacion]
    else
      @caja.situacion
    end
  end

  def adaptar_formulario_caja
    if valor_situacion == "efectivo"
      content_for :stylesheets do
        '#form_banco {display: none}'
      end
    else
      content_for :stylesheets do
        '#form_caja {display: none}'
      end
    end
  end

  def caja_o_cuenta
    if ( @caja.efectivo? ) or ( params[:situacion] == 'efectivo' )
      'Caja'
    else
      'Cuenta'
    end
  end

end
