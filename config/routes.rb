Cp::Application.routes.draw do
  root 'obras#index'

  # /obra
  resources :obras do

    # /obra/caja
    resources :cajas do
      collection do
        get 'transferencia'
        get 'cambio_moneda'
      end
    end

    # /obra/factura
    resources :facturas do
      # Filtrar facturas por situacion
      collection do
        get 'cobros'
        get 'pagos'
      end

      # /obra/factura/recibo - Ver los recibos de cada factura para esta obra
      resources :recibos

      # /obra/factura/retención - Ver las retenciones de cada factura para esta obra
      resources :retenciones
    end

    # /obra/recibo/* pero no crear recibos sin facturas asociadas
    resources :recibos, except: [ :index, :new ] do
      collection do
        get 'cobros'
        get 'pagos'
      end
    end

    # /obra/cheque
    resources :cheques, only: [ :index, :show ] do
      collection do
        get 'propios'
        get 'terceros'
      end
    end

    # /obra/retención
    resources :retenciones, only: [ :index, :show ]
  end

  # /caja
  resources :cajas do
    collection do
      get 'transferencia'
      get 'cambio_moneda'
    end
  end

  # /factura
  resources :facturas, except: [ :index ] do
    collection do
      # Filtrar facturas por situacion
      get 'cobros'
      get 'pagos'

      # Autocompletar Terceros
      get :autocomplete_tercero_nombre
      get :autocomplete_tercero_cuit
    end

    # /factura/recibo - Ver los recibos de cada factura
    resources :recibos

    resources :causas, only: [ :new ]

    # /factura/retención - Ver las retenciones de cada factura
    resources :retenciones
  end

  # /recibo/* - No crear recibos sin facturas asociadas
  resources :recibos, except: [ :new, :index, :create ] do
    collection do
      get 'cobros'
      get 'pagos'
    end
  end

  # /tercero
  resources :terceros

  # /cheque
  # TODO borrar ':new' cuando ya exista interfase de carga
  resources :cheques, only: [ :index, :show, :new, :create, :update, :destroy, :edit ] do
    collection do
      get 'propios'
      get 'terceros'
    end
  end

  # /retención
  resources :retenciones, only: [ :index, :show ]
end
