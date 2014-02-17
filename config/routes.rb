Cp::Application.routes.draw do
  root 'obras#index'

  resources :obras do
    resources :cajas
  end

  resources :cuentas

  resources :facturas do
  # Filtrar facturas por situacion
    collection do
      get 'cobros'
      get 'pagos'
    end
    resources :recibos
  end

  resources :terceros
end
