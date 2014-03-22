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

  def caja_o_cuenta
    if ( @caja.efectivo? ) or ( params[:situacion] == 'efectivo' )
      'Caja'
    else
      'Cuenta'
    end
  end

end
