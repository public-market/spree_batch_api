require 'dry-validation'

module Spree
  module Inventory
    module Providers
      PERMITTED_CONDITIONS = ['New', 'Like New', 'Excellent', 'Very Good', 'Good', 'Acceptable'].freeze
      TAXONOMY = 'Categories'.freeze
      ISBN_PROPERTY = 'isbn'.freeze
      CONDITION_OPTION_TYPE = 'condition'.freeze

      # Default variant provider inventory format
      UploadItemSchema = ::Dry::Validation.Schema do
        required(:ean).filled(:str?)
        required(:sku).filled(:str?)
        required(:quantity).filled(:int?)
        required(:price).filled(:decimal?)
        required(:condition).value(included_in?: PERMITTED_CONDITIONS)
        optional(:notes).str?
        optional(:seller).str?
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
          isbn = hash[:ean]
          product = find_product(isbn)

          Product.transaction do
            product ||= create_product(isbn)
            upsert_variant(product, hash)
          end
        end

        def find_product(isbn)
          Product.joins(:properties)
                 .where(spree_properties: { name: ISBN_PROPERTY },
                        spree_product_properties: { value: isbn })
                 .first
        end

        # rubocop:disable Metrics/AbcSize
        def create_product(isbn)
          metadata = metadata_provider.call(isbn)
          raise ImportError, t('no_isbn') if metadata.blank?

          create_stock_location

          product = build_new_product(metadata)
          build_product_master(product, metadata)

          product.product_option_types.build(option_type: condition_option_type)
          product.save!

          set_properties(product, metadata[:properties])
          categorize(product, metadata[:taxons])

          product
        end
        # rubocop:enable Metrics/AbcSize

        def build_new_product(metadata)
          Product.new(
            name: metadata[:title],
            price: metadata[:price],
            description: metadata[:description],
            meta_description: metadata[:description],
            meta_title: metadata[:title],
            meta_keywords: metadata.dig(:properties, :subject),
            shipping_category: ShippingCategory.first_or_create(name: 'Default'),
            available_on: Time.current
          )
        end

        def build_product_master(product, metadata)
          product.master.assign_attributes(variant_attributes(metadata))
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
          taxonomy = Spree::Taxonomy.create_with(filterable: true).find_or_create_by!(name: taxonomy_name)

          parent_taxon = taxonomy.root
          taxons.each do |taxon|
            parent_taxon = parent_taxon.children.find_or_create_by!(name: taxon, taxonomy: taxonomy)
          end
          parent_taxon.products << product
        end

        def upsert_variant(product, item)
          variant = Variant.unscoped
                           .where(sku: item[:sku], product: product)
                           .first_or_initialize
          variant.price = variant.cost_price = item[:price]
          variant.notes = item[:notes] if variant.respond_to?(:notes)
          update_variant_hook(variant, item) # run this before options association set
          variant.options = [{ name: CONDITION_OPTION_TYPE, value: item[:condition] }]

          variant.save!

          process_variant_quantity(variant, item[:quantity])
        end

        def process_variant_quantity(variant, quantity)
          stock_item = variant.stock_items.first
          stock_item.set_count_on_hand(quantity)
          variant
        end

        def variant_attributes(metadata)
          dims = metadata[:dimensions]
          {
            is_master: true,
            weight: dims[:weight],
            height: dims[:height],
            width: dims[:width],
            depth: dims[:depth]
          }
        end

        def isbn_property
          Property.create_with(presentation: I18n.t('properties.isbn'))
                  .find_or_create_by(name: ISBN_PROPERTY)
        end

        def condition_option_type
          option_type_attrs = {
            name: CONDITION_OPTION_TYPE,
            presentation: 'Condition',
            option_values_attributes: PERMITTED_CONDITIONS.map { |c| { name: c, presentation: c } }
          }

          OptionType.where(name: option_type_attrs[:name]).first_or_create(option_type_attrs)
        end

        def create_stock_location
          StockLocation.create_with(backorderable_default: false).first_or_create(name: 'default')
        end

        def metadata_provider
          Spree::Config.product_metadata_provider.constantize
        end

        def taxonomy_name
          options&.dig(:taxonomy) || TAXONOMY
        end

        def update_variant_hook(variant, item)
          # Hook for extending variants
        end
      end
    end
  end
end
