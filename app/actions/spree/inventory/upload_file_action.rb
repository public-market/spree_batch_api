module Spree
  module Inventory
    class UploadFileAction < BaseAction
      param :format
      param :file_path
      option :upload_options, optional: true, default: proc { {} }

      UPLOAD_BUCKET = 'inventory_uploads'.freeze
      SUPPORTED_FORMATS = %w[csv json].freeze

      def call
        check_format

        upload = create_upload
        job_id = UploadInventoryWorker.perform_async(upload.id.to_s, format, file_path)

        upload.update(job_id: job_id)
        upload.reload
      rescue Spree::ImportError => e
        { errors: e.message.to_s }
      end

      private

      def check_format
        raise Spree::ImportError, t('unsupported_format') unless SUPPORTED_FORMATS.include?(format)
      end

      def create_upload
        Upload.create(**upload_options)
      end
    end
  end
end
