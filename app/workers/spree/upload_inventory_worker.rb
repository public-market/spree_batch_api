require 'sidekiq'

module Spree
  class UploadInventoryWorker
    include Sidekiq::Worker
    sidekiq_options queue: :upload, retry: false, backtrace: true

    attr_reader :upload

    def perform(upload_id, format, filepath, opts = {})
      @upload = Upload.find_by(id: upload_id)

      local_file = load_file(filepath)
      upload_action(format, local_file, opts)
    end

    private

    def load_file(filepath)
      filepath
    end

    def upload_action(format, local_file, opts) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      case format
      when 'json'
        payload = File.read(local_file)
        Inventory::JsonImportAction.call(payload, upload: upload, options: options.merge(opts))
      when 'csv'
        Inventory::CSVImportAction.call(local_file, upload: upload, options: options.merge(opts))
      when 'csv_tab'
        csv_opts = {
          col_sep: "\t",
          headers: true,
          quote_char: "\x00",
          converters: [->(s) { s&.strip }],
          header_converters: ->(h) { h&.downcase }
        }
        Inventory::CSVImportAction.call(local_file, upload: upload, csv_options: csv_opts, options: options.merge(opts))
      end
    end

    # allow to override data passed to import actions
    def options
      {}
    end
  end
end
