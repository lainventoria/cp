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
        { form_caja: 'hidden',
          form_banco: '' }
      else
        { form_caja: '',
          form_banco: 'hidden' }
    end
  end

  def ver_en_caja
    @caja.efectivo? ? '' : 'hidden'
  end

  def ver_en_cuenta
    @caja.banco? ? '' : 'hidden'
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

  def ocultar_en_chequera
    caja_o_cuenta == 'Chequera' ? 'hidden' : ''
  end

  def obra_caja
    @caja.new_record? ? params[:obra_id] : @caja.obra_id
  end

  def establece_parametros_listado_cajas(situacion)
    case situacion
      when 'efectivo'
        lista_caja = ''
        lista_banco = 'hidden'
        ocultar_en_chequera = ''
      when 'banco'
        lista_caja = 'hidden'
        lista_banco = ''
        ocultar_en_chequera = ''
      when 'chequera'
        lista_caja = 'hidden'
        lista_banco = 'hidden'
        ocultar_en_chequera = 'hidden'
    end

    return [ lista_caja, lista_banco, ocultar_en_chequera ]
  end
end
