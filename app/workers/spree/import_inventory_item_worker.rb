require 'sidekiq'

module Spree
  class ImportInventoryItemWorker
    include Sidekiq::Worker
    sidekiq_options queue: :upload, retry: 3, backtrace: true

    # rubocop:disable Metrics/MethodLength
    def perform(item_json, options)
      @upload = Upload.find_by(id: options['upload_id'])

      begin
        inventory_provider.call(item_json.with_indifferent_access, options: options.with_indifferent_access)
      rescue ImportError => e
        catch_error(ImportError.new(
                      I18n.t('workers.spree.import_inventory_item_worker.invalid_item',
                             index: options['index'],
                             messages: e.message),
                      e.object
        ))
      end

      @upload.increment!(:processed) # rubocop:disable Rails/SkipsModelValidations
    end
    # rubocop:enable Metrics/MethodLength

    private

    def inventory_provider
      Spree::Inventory::Providers::DefaultVariantProvider
    end

    def catch_error(error)
      @upload.upload_errors.create(message: error.message)
    end
  end
end
