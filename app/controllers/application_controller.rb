class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

    # Hay que declararlo antes que cualquier otro before_action en los
    # controladores que lo necesiten
    def set_obra
      @obra = params[:obra_id].present? ? Obra.find(params[:obra_id]) : nil
    end

    # Este va inmediatamente después de set_obra, si se usa
    def set_factura
      if params[id_para_factura]
        @factura = (@obra.present? ? @obra.facturas : Factura).find(params[id_para_factura])
      end
    end

    # para cargar las columnaas por que ordenar
    def set_order
      sort = params[:sort].present? ? params[:sort] : 'id'
      if sort == 'terceros_nombre'
        sort = 'terceros.nombre'
      end
      ord = params[:order].present? ? params[:order].upcase() : 'ASC'
      @order = sort + ' ' + ord
    end

    # set_factura lo usa para determinar cómo cargar la factura
    def id_para_factura
      params[:controller] == 'facturas' ? :id : :factura_id
    end

    # No dejar que el usuario hax0r invente causas
    def causas_conocidas
      %w{ cheque-propio cheque-de-terceros efectivo transferencia retenciones }
    end

    # Devuelve la clase de la causa según el tipo
    def modelo_de_causa
      if causas_conocidas.include? params[:causa_tipo]
        case params[:causa_tipo]
          when 'cheque-de-terceros', 'cheque-propio'
            Cheque
          when 'retenciones'
            Retencion
          else
            params[:causa_tipo].underscore.classify.constantize
        end
      else
        # TODO Null object?
        nil
      end
    end

    # TODO pedir permits según causa
    def causa_params
      if params[:causa].present?
        params[:causa].permit(
          :monto, :monto_moneda, :caja_id, :cheque_id, :retencion_id,
          :monto_aceptado, :monto_aceptado_moneda,
          :cuenta_id, :chequera_id, :numero, :fecha_emision, :beneficiario,
          :fecha_vencimiento
        )
      else
        {}
      end
    end
end
