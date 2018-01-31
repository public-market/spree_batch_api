require 'sidekiq'
require 'sidekiq-status'

module Spree
  class UploadInventoryWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker

    attr_reader :upload

    def perform(upload_id, format, filepath)
      @upload = Upload.find_by(id: upload_id)

      local_file = filepath
      begin
        upload_action(format, local_file)
        upload.complete!
      rescue Spree::ImportError => e
        catch_error(e)
        upload.fail!
      end
    end

    def catch_error(error)
      upload.upload_errors.create(message: error.message)
    end

    private

    def upload_action(format, local_file)
      case format
      when 'json'
        payload = File.read(local_file)
        Inventory::JsonImportAction.call(self, payload)
      when 'csv'
        Inventory::CSVImportAction.call(self, local_file)
      end
    end
  end
end
