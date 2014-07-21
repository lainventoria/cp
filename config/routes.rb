Rails.application.routes.draw do
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

      # /obra/factura/recibo
      # Ver los recibos de cada factura para esta obra
      # TODO acciones que sobran?
      resources :recibos, except: [ :index ]

      # /obra/factura/retención
      # Ver las retenciones de cada factura para esta obra
      resources :retenciones
    end

    # /obra/recibo/* pero no crear recibos sin facturas asociadas
    resources :recibos, except: [ :new, :index ] do
      collection do
        get 'cobros'
        get 'pagos'
      end
    end

    # /obra/caja
    resources :cajas do

      member do
       get 'cambiar'
       get 'transferir'
      end

      # /obra/caja/cheque
      resources :cheques do
        member do
          patch 'depositar'
          patch 'cobrar'
          patch 'pagar'
        end
      end

      # /obra/caja/retencion
      resources :retenciones

    end

    # /obra/unidad_funcional
    resources :unidades_funcionales

    # /obra/retención
    resources :retenciones, only: [ :index, :show ]
    # /obra/cheque
    # no se editan cheques aca, solo se listan
    resources :cheques
  end

  # /caja
  resources :cajas do
    member do
      get 'cambiar'
      get 'transferir'
      patch 'operar'
    end

    # /caja/cheque
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

  # /indice
  resources :indices

  # /cheque
  # TODO borrar ':new' cuando ya exista interfase de carga
  resources :cheques, only: [ :index ]

  # /retención
  resources :retenciones, only: [ :index, :show ]
end
