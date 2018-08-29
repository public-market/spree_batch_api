require 'dry-validation'

module Spree
  class Upload < Spree::Base
    has_many :upload_errors, dependent: :destroy

    validate :metadata_schema

    METADATA_SCHEMA =
      ::Dry::Validation.Schema do
        configure do
          option :permitted_product_types
          option :supported_formats
        end

        required('file_path').filled
        required('format').value(included_in?: supported_formats)
        required('product_type').value(included_in?: permitted_product_types)
      end

    self.whitelisted_ransackable_attributes = %w[job_id]

    def status
      total.present? && total == processed ? 'completed' : 'processing'
    end

    class << self
      def supported_formats
        %w[csv csv_tab json].freeze
      end

      def supported_product_types
        %w[fake].freeze
      end
    end

    private

    def metadata_schema
      result = METADATA_SCHEMA.with(permitted_product_types: self.class.supported_product_types, supported_formats: self.class.supported_formats)
                              .call(metadata)

      return if result.success?
      errors.add(:metadata, result.messages)
    end
  end
end
