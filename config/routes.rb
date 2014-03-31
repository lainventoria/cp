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
  end

  # Permitir /recibos pero no crear recibos sin facturas asociadas
  resources :recibos, except: [ :new, :index, :create ] do
    collection do
      get 'cobros'
      get 'pagos'
    end
  end

  resources :terceros

  # TODO borrar ':new' cuando ya exista interfase de carga
  resources :cheques, only: [ :index, :show, :new, :create, :update, :destroy, :edit ] do
    collection do
      get 'propios'
      get 'terceros'
    end
  end

  resources :retenciones
end
