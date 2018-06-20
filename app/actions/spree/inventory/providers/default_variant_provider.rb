require 'dry-validation'

module Spree
  module Inventory
    module Providers
      # Default variant provider inventory format
      UploadItemSchema = ::Dry::Validation.Schema do
        required(:sku).filled(:str?)
        required(:quantity).filled(:int?)
        required(:price).filled(:decimal?)
        optional(:notes).str?
      end

      class DefaultVariantProvider < Spree::BaseAction # rubocop:disable Metrics/ClassLength
        param :item_json
        option :options, optional: true, default: proc { {} }

        def call
          item_hash = validate_item(cast_values(item_json))
          process_item(item_hash)
        end

        protected

        def cast_values(item_json)
          item_json[:quantity] = item_json[:quantity].to_s.to_i
          item_json[:price] = item_json[:price].to_s.to_f.to_d
          item_json
        end

        def validate_item(item_json)
          result = UploadItemSchema.call(item_json)
          messages = result.messages
          raise ImportError.new(messages.to_s, messages) if result.failure?
          result.to_h
        end

        def process_item(hash)
          identifier = product_identifier(hash)
          product = find_product(identifier)

          Product.transaction do
            product ||= create_product(identifier)
            upsert_variant(product, hash)
          end
        end

        def product_identifier(_hash)
          raise NotImplementedError, 'product_identifier'
        end

        def find_product(_identifier)
          raise NotImplementedError, 'find_product'
        end

        # rubocop:disable Metrics/AbcSize
        def create_product(identifier)
          metadata = find_metadata(identifier)
          raise ImportError, t('metadata_not_found') if metadata.blank?

          create_stock_location

          product = build_new_product(metadata)
          build_product_master(product, metadata)

          product.product_option_types.build(product_option_types_attrs)
          product.save!

          set_properties(product, metadata[:properties])
          categorize(product, metadata[:taxons])

          product
        end
        # rubocop:enable Metrics/AbcSize

        def find_metadata(identifier)
          metadata_provider.call(identifier)
        end

        def metadata_provider
          self.class.parent::MetadataProvider
        end

        def product_option_types_attrs
          {}
        end

        def build_new_product(metadata)
          Product.new(product_attrs(metadata))
        end

        def product_attrs(metadata)
          {
            name: metadata[:title],
            price: metadata[:price]
          }
        end

        def build_product_master(product, metadata)
          product.master.assign_attributes(master_variant_attributes(metadata))
          return if metadata[:images].blank?
          metadata[:images].each do |img|
            product.master.images.build(
              alt: img[:title],
              attachment: img[:file] || URI.parse(img[:url])
            )
          end
        end

        def set_properties(product, properties)
          properties.each do |property_name, property_value|
            if property_value.present?
              product.set_property(property_name, property_value, I18n.t("properties.#{property_name}", default: property_name.to_s.humanize))
            end
          end
        end

        def categorize(product, taxons)
          taxonomy = Spree::Taxonomy.find_or_create_by!(name: taxonomy_name)

          parent_taxon = taxonomy.root
          taxons.each do |taxon|
            parent_taxon = parent_taxon.children.find_or_create_by!(name: taxon, taxonomy: taxonomy)
          end
          parent_taxon.products << product
        end

        def upsert_variant(product, item)
          variant = fetch_variant(product, item)
          variant.price = variant.cost_price = item[:price]
          variant.notes = item[:notes] if variant.respond_to?(:notes)
          update_variant_hook(variant, item) # run this before options association set
          variant.options = variant_options(item)

          variant.save!

          process_variant_quantity(variant, item[:quantity])
        end

        def variant_options(item)
          [{ name: condition_option_name, value: item[:condition] }]
        end

        def fetch_variant(product, item)
          Variant.unscoped.where(sku: item[:sku], product: product).first_or_initialize
        end

        def process_variant_quantity(variant, quantity)
          stock_item = variant.stock_items.first
          stock_item.set_count_on_hand(quantity)
          variant
        end

        def master_variant_attributes(_metadata)
          {}
        end

        def create_stock_location
          StockLocation.create_with(backorderable_default: false).first_or_create(name: 'default')
        end

        def taxonomy_name
          options&.dig(:taxonomy) || self.class.parent::TAXONOMY
        end

        def update_variant_hook(variant, item)
          # Hook for extending variants
        end
      end
    end
  end
end
