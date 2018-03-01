require 'csv'

module Spree
  module Inventory
    class CSVImportAction < BaseImportAction
      param :local_file

      def map_items
        index = 0
        CSV.foreach(local_file, headers: true, encoding: 'ISO8859-1') do |row|
          yield(item_json(row), index)
          index += 1
        end
        status_worker&.total(index)
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
