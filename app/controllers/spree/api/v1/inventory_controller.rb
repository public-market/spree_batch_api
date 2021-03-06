module Spree
  module Api
    module V1
      class InventoryController < Spree::Api::BaseController
        def update
          authorize!(:create, Product)
          file_path = save_content

          options = {
            format: params[:content_format],
            file_path: file_path,
            provider: inventory_params[:provider],
            product_type: inventory_params[:product_type]
          }.merge(additional_inventory_params)

          @upload = Inventory::UploadFileAction.call(options)
        end

        private

        def save_content
          FileUtils.mkdir_p('tmp/uploads')
          file = File.open("tmp/uploads/#{SecureRandom.urlsafe_base64}", 'w')
          file.write(request.body.read)
          file.close
          file.path
        end

        def additional_inventory_params
          {}
        end

        def inventory_params
          params.permit(:product_type, :provider)
        end
      end
    end
  end
end
