Cp::Application.routes.draw do
  root 'obras#index'

  resources :obras do
    resources :cajas
  end

  resources :cuentas

  resources :facturas do
    resources :recibos
  end

  resources :terceros
end
