module Spree
  module Inventory
    class BaseImportAction < Spree::BaseAction
      option :options, optional: true, default: proc { {} }
      option :upload

      def call
        total = 0
        map_items do |item_json, index|
          Spree::ImportInventoryItemWorker.perform_async(
            item_json,
            options.merge(upload_id: upload.id, index: index)
          )
          total += 1
        end

        upload.update(total: total)
      end

      protected

      def map_items
        raise NotImplementedError, 'map_items'
      end
    end
  end
end
