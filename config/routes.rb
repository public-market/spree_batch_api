Spree::Core::Engine.add_routes do
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      post '/inventory/:content_format(/:product_type)', to: 'inventory#update', defaults: { product_type: 'books' }
    end
  end

  namespace :admin do
    resources :uploads, only: %i[index show]
  end
end
