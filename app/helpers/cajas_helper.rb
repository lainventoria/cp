module CajasHelper

  def valor_situacion
    if @caja.new_record?
      params[:situacion]
    else
      @caja.situacion
    end
  end

  def opciones_formulario_caja
    case valor_situacion
      when 'banco'
        { form_caja: "hidden",
          form_banco: "" }
      else
        { form_caja: "",
          form_banco: "hidden" }
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
    elsif ( @caja.banco? ) or ( params[:situacion] == 'banco' )
      'Cuenta'
    else
      'Chequera'
    end
  end

  def ocultar_en_chequera
    caja_o_cuenta == 'Chequera' ? 'hidden' : ''
  end

  def obra_caja
    @caja.new_record? ? params[:obra_id] : @caja.obra_id
  end
end
