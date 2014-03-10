module RecibosHelper
  
  def recibos_por_tipo_path  
    if @recibo.pago?
      pagos_recibos_path
    else
      cobros_recibos_path
    end
  end

end
