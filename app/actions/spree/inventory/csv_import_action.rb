require 'csv'

module Spree
  module Inventory
    class CSVImportAction < BaseImportAction
      param :local_file
      option :csv_options, optional: true, default: proc { {} }

      def map_items
        csv_opts = { headers: true, encoding: 'ISO8859-1' }.merge(csv_options)

        index = 0
        CSV.foreach(local_file, csv_opts) do |row|
          yield(item_json(row), index)
          index += 1
        end
      rescue Errno::ENOENT
        raise ImportError, t('invalid_csv.default')
      end

      private

      def item_json(row)
        row.to_hash.with_indifferent_access
      end
    end
  end
end
