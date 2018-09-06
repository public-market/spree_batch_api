require 'dry-validation'

module Spree
  module Inventory
    module Providers
      class DefaultVariantProvider < Spree::BaseAction # rubocop:disable Metrics/ClassLength
        VALIDATION_SCHEMA =
          ::Dry::Validation.Schema do
            required(:sku).filled(:str?)
            required(:quantity).filled(:int?)
            required(:price).filled(:decimal?)
            optional(:notes).str?
          end

        param :item_json
        option :options, optional: true, default: proc { {} }

        def call
          item_hash = validate_item(cast_values(item_json))
          Taxon.no_touching { process_item(item_hash) }
        end

        protected

        def cast_values(item_json)
          item_json[:quantity] = cast(item_json[:quantity]) { |v| v.to_i }
          item_json[:price] = cast(item_json[:price]) { |v| v.to_f.to_d }
          item_json
        end

        def cast(value)
          str = value.to_s
          str.empty? ? str : yield(str)
        end

        def upload_item_schema
          self.class::VALIDATION_SCHEMA || VALIDATION_SCHEMA
        end

        def validate_item(item_json)
          result = upload_item_schema.with(validation_options).call(item_json)
          messages = result.messages
          raise ImportError.new(messages.to_s, messages) if result.failure?
          result.to_h
        end

        def validation_options
          {}
        end

        def process_item(hash)
          variant = find_variant(variant_sku(hash))
          if variant.present?
            update_variant(variant, hash)
          else
            variant = create_variant(hash)
          end

          create_product_upload(variant)
          variant
        end

        def create_variant(hash)
          identifier = product_identifier(hash)
          product = find_product(identifier) || create_product(identifier)

          variant = Variant.new(sku: variant_sku(hash), product_id: product.id)
          update_variant(variant, hash)
        end

        def create_product_upload(variant)
          ProductUpload.create(product_id: variant.product_id, upload_id: options[:upload_id])
        end

        def product_identifier(_hash)
          raise NotImplementedError, 'product_identifier'
        end

        def find_product(identifier)
          Product.joins(:master).find_by(spree_variants: { sku: identifier })
        end

        def variant_sku(hash)
          hash[:sku]
        end

        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def create_product(identifier)
          metadata = find_metadata(identifier)
          raise ImportError, t('metadata_not_found', default: I18n.t('actions.spree.inventory.providers.default_variant_provider.metadata_not_found')) if metadata.blank?

          create_stock_location

          product = build_new_product(metadata)
          build_product_master(product, metadata)

          product.master.sku = identifier
          build_option_types(product)

          # Double check existing product
          existing_product = find_product(identifier)
          return existing_product if existing_product.present?

          Product.transaction do
            product.save!

            set_properties(product, metadata[:properties])
            categorize(product, metadata[:taxons])
          end

          product
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

        def find_metadata(identifier)
          metadata_provider.call(identifier)
        end

        def metadata_provider
          Fake::MetadataProvider
        end

        def build_option_types(product)
          option_types.each do |type|
            product.product_option_types.build(option_type: option_type_attrs(type))
          end
        end

        def option_type_attrs(type)
          attrs = { name: type[:name], presentation: type[:presentation] }
          attrs[:option_values_attributes] = type[:values] if type[:values].present?

          OptionType.where(name: type[:name]).first_or_create(attrs)
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

        def update_variant(variant, item)
          variant.price = variant.cost_price = item[:price]
          variant.notes = item[:notes] if variant.respond_to?(:notes)
          update_variant_hook(variant, item)
          variant.build_options(variant_options(item))

          variant.save!

          process_variant_quantity(variant, item[:quantity])
        end

        def variant_options(item)
          option_types.map { |type| { name: type[:name], value: variant_option_value(item, type) } }
        end

        def variant_option_value(item, option_type)
          item.dig(option_type[:name].to_sym)
        end

        def find_variant(sku)
          Variant.unscoped.find_by(sku: sku)
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
