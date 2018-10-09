require 'sidekiq'

module Spree
  class ImportInventoryItemWorker
    include Sidekiq::Worker
    sidekiq_options retry: 3, backtrace: true

    def perform(upload_item_id)
      item = UploadItem.find(upload_item_id)
      upload = item.upload

      options = item.options
      options.merge!(upload.metadata)

      begin
        inventory_provider(options).call(item.item_json.with_indifferent_access, options: options.with_indifferent_access)
      rescue ImportError => e
        self.class.catch_error(item, e.message)
      end

      item.destroy!

      self.class.increment_processed(upload)
    end

    sidekiq_retries_exhausted do |msg, _ex|
      Sidekiq.logger.error "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
      item = UploadItem.find(msg.dig('args', 0))
      increment_processed(item.upload)
      catch_error(item, msg['error_message'])
      item.destroy!
    end

    def inventory_provider(options)
      product_type = options['product_type'] || ''
      provider = options['provider'] || ''

      provider_class = [
        product_type.parameterize(separator: '_').camelize,
        "#{provider.parameterize(separator: '_').camelize}VariantProvider"
      ].join('::')

      Spree::Inventory::Providers.const_get(provider_class)
    rescue NameError
      raise Spree::ImportError, I18n.t('workers.spree.import_inventory_item_worker.unsupported_variant_provider', product_type: product_type, provider: provider)
    end

    def self.increment_processed(upload)
      upload.increment!(:processed) # rubocop:disable Rails/SkipsModelValidations
    end

    def self.catch_error(item, error_message)
      item.upload.upload_errors.create(message: I18n.t('workers.spree.import_inventory_item_worker.invalid_item',
                                       index: item.index,
                                       messages: error_message))
    end
  end
end
