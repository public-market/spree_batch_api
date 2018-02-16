module Spree
  module Api
    module V1
      class InventoryController < Spree::Api::BaseController
        def update
          authorize! :create, Product
          file_path = save_content
          @upload = Inventory::UploadFileAction.call(params[:content_format], file_path)
        end

        private

        def save_content
          FileUtils.mkdir_p('tmp/uploads')
          file = File.open("tmp/uploads/#{SecureRandom.urlsafe_base64}", 'w')
          file.write(request.body.read)
          file.close
          file.path
        end
      end
    end
  end
end
