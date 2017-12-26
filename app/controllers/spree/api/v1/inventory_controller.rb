module Spree
  module Api
    module V1
      class InventoryController < Spree::Api::BaseController
        def update
          authorize! :create, Product

          @success = 0
          inventory_params[:products].each do |product_params|
            @success += 1
          end
        end

        private

        def inventory_params
          params.require(:products)
          params.permit(products: [permitted_product_attributes])
        end
      end
    end
  end
end
