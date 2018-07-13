require 'sidekiq'

module Spree
  class ImportInventoryItemWorker
    include Sidekiq::Worker
    sidekiq_options queue: :upload, retry: 3, backtrace: true

    def perform(item_json, options)
      upload = self.class.load_upload(options)

      begin
        inventory_provider(options).call(item_json.with_indifferent_access, options: options.with_indifferent_access)
      rescue ImportError => e
        self.class.catch_error(upload, options, e.message)
      end

      self.class.increment_processed(upload)
    end

    sidekiq_retries_exhausted do |msg, _ex|
      Sidekiq.logger.error "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
      options = msg.dig('args', 1)
      upload = load_upload(options)
      increment_processed(upload)
      catch_error(upload, options, msg['error_message'])
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

    def self.load_upload(options)
      Upload.find_by(id: options['upload_id'])
    end

    def self.increment_processed(upload)
      upload.increment!(:processed) # rubocop:disable Rails/SkipsModelValidations
    end

    def self.catch_error(upload, options, error_message)
      upload.upload_errors.create(message: I18n.t('workers.spree.import_inventory_item_worker.invalid_item',
                                                  index: options['index'],
                                                  messages: error_message))
    end
  end
end
