Spree::Core::Engine.add_routes do
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      post '/inventory/:content_format', to: 'inventory#update'
      get '/orders/fetch', to: 'batch_orders#fetch'
      post '/orders/update_shipments', to: 'batch_orders#update_shipments'
    end
  end

  namespace :admin do
    resources :uploads, only: %i[index show]
  end
end
