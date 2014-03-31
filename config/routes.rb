Cp::Application.routes.draw do
  root 'obras#index'

  resources :obras do

    resources :cajas

    resources :facturas do
    # Filtrar facturas por situacion
      collection do
        get 'cobros'
        get 'pagos'
      end

      # Ver los recibos de cada factura
      resources :recibos

      # Ver las retenciones de cada factura
      resources :retenciones
    end

    # Permitir /recibos pero no crear recibos sin facturas asociadas
    resources :recibos, except: [ :new ] do
      collection do
        get 'cobros'
        get 'pagos'
      end
    end

    resources :cheques, only: [ :index, :show ] do
      collection do
        get 'propios'
        get 'terceros'
      end
    end

    resources :retenciones, only: [ :index, :show ]
  end

  resources :cajas

  resources :facturas, except: [ :index ] do
  # Filtrar facturas por situacion
    collection do
      get 'cobros'
      get 'pagos'
    end

    # Autocompletar Terceros
    get :autocomplete_tercero_nombre, :on => :collection
    get :autocomplete_tercero_cuit, :on => :collection

    # Ver los recibos de cada factura
    resources :recibos

    resources :causas, only: [ :new ]

    # Ver las retenciones de cada factura
    resources :retenciones
  end

  # Permitir /recibos pero no crear recibos sin facturas asociadas
  resources :recibos, except: [ :new, :index, :create ] do
    collection do
      get 'cobros'
      get 'pagos'
    end
  end

  resources :terceros

  resources :cheques, only: [ :index, :show ] do
    collection do
      get 'propios'
      get 'terceros'
    end
  end

  resources :retenciones, except: [ :new ]
end
