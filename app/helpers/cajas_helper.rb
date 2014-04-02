module CajasHelper

  def valor_situacion
    if @caja.new_record? 
      params[:situacion]
    else
      @caja.situacion
    end
  end
  
  def opciones_formulario_caja
    if valor_situacion == "efectivo"
      { form_caja: "", form_banco: "hidden" }
    else
      { form_caja: "hidden", form_banco: "" }
    end
  end

  def ver_en_caja
    @caja.efectivo? ? "" : "hidden"
  end

  def ver_en_cuenta
    @caja.banco? ? "" : "hidden"
  end

  def caja_o_cuenta(caja = @caja)
    if ( caja.efectivo? ) or ( params[:situacion] == 'efectivo' )
      'Caja'
    elsif ( caja.banco? ) or ( params[:situacion] == 'banco' )
      'Cuenta'
    else
      'Chequera'
    end
  end

  def obra_caja
    @caja.new_record? ? params[:obra_id] : @caja.obra_id
  end
end
