require 'sidekiq'

module Spree
  class UploadInventoryWorker
    include Sidekiq::Worker
    sidekiq_options retry: false, backtrace: true

    attr_reader :upload

    def perform(upload_id)
      @upload = Upload.find_by(id: upload_id)

      return if @upload.blank?

      @upload.upload_errors.delete_all
      @upload.upload_items.delete_all
      @upload.update(total: 0, processed: 0)

      metadata = @upload.metadata

      filepath = metadata['file_path']

      local_file = load_file(filepath)
      upload_action(local_file, metadata['format'])
    end

    private

    def load_file(filepath)
      filepath
    end

    def upload_action(local_file, format) # rubocop:disable Metrics/MethodLength
      case format
      when 'json'
        payload = File.read(local_file)
        Inventory::JsonImportAction.call(payload, upload: upload, options: options)
      when 'csv'
        Inventory::CSVImportAction.call(local_file, upload: upload, options: options)
      when 'csv_tab'
        csv_opts = {
          col_sep: "\t",
          headers: true,
          quote_char: "\x00",
          converters: [->(s) { s&.strip }],
          header_converters: ->(h) { h&.downcase }
        }
        Inventory::CSVImportAction.call(local_file, upload: upload, csv_options: csv_opts, options: options)
      end
    end

    # allow to override data passed to import actions
    def options
      {}
    end
  end
end
