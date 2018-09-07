Spree::Core::Engine.add_routes do
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      post '/inventory/:content_format(/:product_type)', to: 'inventory#update', defaults: { product_type: 'generic' }
    end
  end

  namespace :admin, path: Spree.admin_path do
    resources :uploads, only: %i[index show]

    resources :products do
      member do
        get :inventory_uploads
      end
    end
  end
end
