module Spree
  module Inventory
    class BaseImportAction < Spree::BaseAction
      option :options, optional: true, default: proc { {} }
      option :upload

      BATCH_SIZE = 1000

      def call # rubocop:disable Metrics/MethodLength
        total = 0
        args = []

        map_items do |item_json, index|
          args << {
            upload_id: upload.id,
            index: index,
            item_json: item_json,
            options: options.merge(upload_id: upload.id, index: index)
          }

          if args.size >= BATCH_SIZE
            push_bulk(args)
            args = []
          end

          total += 1
        end

        push_bulk(args) if args.present?

        upload.update(total: total)
      end

      protected

      def queue_name
        options[:queue_name]
      end

      def map_items
        raise NotImplementedError, 'map_items'
      end

      def push_bulk(args)
        worker = UploadItem.bulk_insert(:upload_id, :index, :item_json, :options, :created_at, :updated_at, return_primary_keys: true)
        worker.add_all(args)
        worker.save!

        Sidekiq::Client.push_bulk('class' => Spree::ImportInventoryItemWorker, 'queue' => queue_name, 'args' => worker.result_sets.first.rows)
      end
    end
  end
end
