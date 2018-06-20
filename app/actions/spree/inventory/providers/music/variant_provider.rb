require 'dry-validation'

module Spree
  module Inventory
    module Providers
      module Music
        PERMITTED_VINYL_CONDITIONS = ['SS', 'M-', 'VG+', 'VG', 'VG-', 'G+'].freeze
        PERMITTED_MUSIC_FORMATS = ['vinyl'].freeze
        TAXONOMY = 'Music'.freeze

        UploadItemSchema = ::Dry::Validation.Schema do
          required(:sku).filled(:str?)
          required(:quantity).filled(:int?)
          required(:price).filled(:decimal?)
          required(:format).filled.value(included_in?: PERMITTED_MUSIC_FORMATS)
          required(:artist).filled(:str?)
          required(:title).filled(:str?)
          required(:description).filled(:str?)
          required(:images).filled
          required(:condition).value(included_in?: PERMITTED_VINYL_CONDITIONS)
          optional(:notes).str?
          optional(:label).str?
          optional(:label_number).str?
          optional(:speed).str?
        end

        class VariantProvider < DefaultVariantProvider
          protected

          def find_metadata(_identifier)
            MetadataProvider.call(item_json.stringify_keys)
          end

          def product_identifier(hash)
            { format: hash[:format], identifier: hash[:sku] }
          end

          def find_product(identifier)
            Product.joins(:properties, :variants)
                   .find_by(
                     spree_variants: { sku: identifier[:identifier] },
                     spree_properties: { name: :music_format },
                     spree_product_properties: { value: identifier[:format] }
                   )
          end

          def product_option_types_attrs
            { option_type: condition_option_type }
          end

          def product_attrs(metadata)
            {
              name: metadata[:title],
              price: metadata[:price],
              description: metadata[:description],
              meta_description: metadata[:description],
              meta_title: metadata[:title],
              shipping_category: ShippingCategory.first_or_create(name: 'Default'),
              available_on: metadata[:available_on].presence || Time.current,
              discontinue_on: metadata[:discontinue_on].presence
            }
          end

          def master_variant_attributes(_metadata)
            {
              is_master: true
            }
          end

          def condition_option_name
            'vinyl_condition'
          end

          def condition_option_type
            option_type_attrs = {
              name: condition_option_name,
              presentation: 'Condition',
              option_values_attributes: PERMITTED_VINYL_CONDITIONS.map { |c| { name: c, presentation: c } }
            }

            OptionType.where(name: option_type_attrs[:name]).first_or_create(option_type_attrs)
          end
        end
      end
    end
  end
end
