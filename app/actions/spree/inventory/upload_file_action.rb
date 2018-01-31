module Spree
  module Inventory
    class UploadFileAction < BaseAction
      param :format
      param :content

      UPLOAD_BUCKET = 'inventory_uploads'.freeze

      def call
        upload = create_upload
        filepath = save_content(upload.id)
        job_id = UploadInventoryWorker.perform_async(upload.id.to_s, format, filepath)

        upload.update(job_id: job_id)
        upload.reload
      end

      private

      def save_content(upload_id)
        file = File.open("/tmp/#{upload_id}", 'w')
        file.write(content)
        file.close
        file.path
      end

      def create_upload
        Upload.create(status: :processing)
      end
    end
  end
end
