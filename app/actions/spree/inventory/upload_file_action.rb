module Spree
  module Inventory
    class UploadFileAction < BaseAction
      param :format
      param :file_path
      option :product_type, optional: true, default: proc { 'books' }
      option :upload_options, optional: true, default: proc { {} }

      UPLOAD_BUCKET = 'inventory_uploads'.freeze
      SUPPORTED_FORMATS = %w[csv json].freeze

      def call
        check_format
        check_product_type

        upload = create_upload
        job_id = UploadInventoryWorker.perform_async(upload.id.to_s, format, file_path, product_type: product_type)

        upload.update(job_id: job_id)
        upload.reload
      rescue Spree::ImportError => e
        { errors: e.message.to_s }
      end

      private

      def check_format
        raise Spree::ImportError, t('unsupported_format') unless SUPPORTED_FORMATS.include?(format)
      end

      def check_product_type
        raise Spree::ImportError, t('unsupported_product_type') unless supported_product_types.include?(product_type)
      end

      def create_upload
        Upload.create(**upload_options)
      end

      def supported_product_types
        %w[books]
      end
    end
  end
end
