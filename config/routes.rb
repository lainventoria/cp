Cp::Application.routes.draw do
  root 'obras#index'

  # /obra
  resources :obras do

    # /obra/factura
    resources :facturas do
      # Filtrar facturas por situacion
      collection do
        get 'cobros'
        get 'pagos'
      end

      # /obra/factura/recibo - Ver los recibos de cada factura para esta obra
      resources :recibos, except: [ :index ]

      # /obra/factura/retención - Ver las retenciones de cada factura para esta obra
      resources :retenciones
    end

    # /obra/recibo/* pero no crear recibos sin facturas asociadas
    resources :recibos, except: [ :new, :index ] do
      collection do
        get 'cobros'
        get 'pagos'
      end
    end

    # /obra/caja/cheque
    resources :cajas do
      resources :cheques do
        member do
          patch 'depositar'
          patch 'cobrar'
          patch 'pagar'
        end
      end
    end

    # /obra/retención
    resources :retenciones, only: [ :index, :show ]
    # no se editan cheques aca, solo se listan
    resources :cheques, only: [ :index, :show, :edit ]
  end

  resources :cajas do
    # no se editan cheques aca, solo se listan
    resources :cheques, only: [ :index, :show, :edit ]
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
    resources :recibos, except: [ :index ]

    # /factura/movimiento
    resources :movimientos, only: [ :new ]

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
  resources :cheques, only: [ :index, :show, :edit ]

  # /retención
  resources :retenciones, only: [ :index, :show ]
end
