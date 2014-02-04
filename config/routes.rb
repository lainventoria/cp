Cp::Application.routes.draw do
  root 'obras#index'

  resources :cuentas
  resources :cajas
  resources :obras
  resources :facturas do
    resources :recibos
  end
  resources :terceros
end
