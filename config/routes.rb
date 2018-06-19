Spree::Core::Engine.add_routes do
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      post '/inventory/:content_format(/:product_type)', to: 'inventory#update', defaults: { product_type: 'books' }
      get '/orders/fetch', to: 'batch_orders#fetch'
      post '/orders/update_shipments', to: 'batch_orders#update_shipments'
    end
  end

  namespace :admin do
    resources :uploads, only: %i[index show]
  end
end
