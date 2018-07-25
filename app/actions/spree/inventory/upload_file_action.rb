module Spree
  module Inventory
    class UploadFileAction < BaseAction
      param :upload_meta

      def call
        upload = create_upload

        if upload.valid?
          job_id = UploadInventoryWorker.perform_async(upload.id.to_s)

          upload.update(job_id: job_id)
          upload.reload
        else
          { errors: upload.errors.full_messages }
        end
      end

      private

      def create_upload
        assign_default_meta
        Upload.create(**upload_options, metadata: upload_meta)
      end

      def upload_options
        {}
      end

      def assign_default_meta
        upload_meta[:product_type] ||= 'fake'
      end
    end
  end
end
