Spree::Core::Engine.add_routes do
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      post '/inventory', to: 'inventory#update'
      get '/orders/fetch', to: 'orders#fetch'
      post '/orders/update_shipments', to: 'orders#update_shipments'
    end
  end
end
