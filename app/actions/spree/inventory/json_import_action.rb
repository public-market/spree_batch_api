module Spree
  module Inventory
    class JsonImportAction < BaseImportAction
      param :payload

      def map_items(&block)
        items = validate_json.dig(:items)
        items.map.with_index(&block)
        status_worker&.total(items.count)
      rescue JSON::ParserError
        raise ImportError, t('invalid_json.default')
      end

      private

      def validate_json
        json = parse_json.with_indifferent_access

        raise ImportError, t('invalid_json.schema', messages: '[items] required') if json[:items].blank?
        json
      end

      def parse_json
        raise ImportError, t('empty_payload') if payload.blank?

        json = JSON.parse(payload)
        raise ImportError, t('invalid_json.hash') unless json.is_a?(Hash)
        json
      end
    end
  end
end
