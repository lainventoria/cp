Cp::Application.routes.draw do
  root 'obras#index'

  resources :obras
  resources :cajas

  resources :facturas, except: [ :index ] do
  # Filtrar facturas por situacion
    collection do
      get 'cobros'
      get 'pagos'
    end

    # Ver los recibos de cada factura
    resources :recibos
  end

  # Permitir /recibos/pagos y /recibos/cobros pero no /recibos
  # No permite crear recibos sin facturas asociadas
  resources :recibos, only: [ :show ] do
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

end
