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

    # Ver los recibos de cada factura
    resources :recibos
  end

  # Permitir /recibos
  resources :recibos do
    collection do
      get 'cobros'
      get 'pagos'
    end
  end

  resources :terceros

  resources :retenciones
end
