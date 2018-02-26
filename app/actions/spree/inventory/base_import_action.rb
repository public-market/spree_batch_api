module Spree
  module Inventory
    class BaseImportAction < Spree::BaseAction
      param :status_worker
      option :inventory_provider, default: proc { Spree::Inventory::Providers::DefaultVariantProvider }
      option :options, optional: true

      def call
        map_items do |item_json, index|
          status_worker&.at(index + 1)
          begin
            inventory_provider.call(item_json, options: options)
          rescue ImportError => e
            error = ImportError.new(t('invalid_item', index: index, messages: e.message), e.object)
            raise error unless status_worker
            status_worker.catch_error(error)
          end
        end
      end

      protected

      def map_items
        raise NotImplementedError, 'map_items'
      end
    end
  end
end
