module Spree
  module Api
    module V1
      class InventoryController < Spree::Api::BaseController
        def update
          authorize! :create, Product
          @upload = Inventory::UploadFileAction.call(inventory_params[:content_format], inventory_params['content'])
        end

        private

        def inventory_params
          params.permit(:content_format, :content)
        end
      end
    end
  end
end
