require 'dry-validation'

module Spree
  class Upload < Spree::Base
    has_many :upload_errors, dependent: :destroy

    validate :metadata_schema

    SUPPORTED_FORMATS = %w[csv csv_tab json].freeze
    SUPPORTED_PRODUCT_TYPES = %w[fake].freeze

    METADATA_SCHEMA =
      ::Dry::Validation.Schema do
        configure do
          option :permitted_product_types
        end

        required('file_path').filled
        required('format').value(included_in?: SUPPORTED_FORMATS)
        required('product_type').value(included_in?: permitted_product_types)
      end

    self.whitelisted_ransackable_attributes = %w[job_id]

    def status
      total.present? && total == processed ? 'completed' : 'processing'
    end

    private

    def metadata_schema
      result = METADATA_SCHEMA.with(permitted_product_types: SUPPORTED_PRODUCT_TYPES).call(metadata)

      return if result.success?
      errors.add(:metadata, result.messages)
    end
  end
end
