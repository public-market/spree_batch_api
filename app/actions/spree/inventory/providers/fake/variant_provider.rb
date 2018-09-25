module Spree
  module Inventory
    module Providers
      module Fake
        class VariantProvider < DefaultVariantProvider
          PERMITTED_CONDITIONS = ['New', 'Like New', 'Excellent', 'Very Good', 'Good', 'Acceptable'].freeze
          VALIDATION_SCHEMA =
            ::Dry::Validation.Schema do
              required(:ean).filled(:str?)
              required(:sku).filled(:str?)
              required(:quantity).filled(:int?)
              required(:price).filled(:decimal?)
              required(:condition).value(included_in?: PERMITTED_CONDITIONS)
              optional(:notes).str?
              optional(:seller).str?
            end

          protected

          def taxonomy_name
            options&.dig(:taxonomy) || 'Categories'
          end

          def product_identifier(hash)
            hash[:ean]
          end

          def product_attrs(metadata)
            super.merge(
              meta_keywords: metadata.dig(:properties, :subject)&.truncate(255), # spree has validation: length maximum - 255,
              shipping_category: ShippingCategory.first_or_create(name: 'Default')
            )
          end

          def option_types
            permitted_conditions = PERMITTED_CONDITIONS.map { |c| { name: c, presentation: c } }
            [{ name: 'condition', presentation: 'Condition', values: permitted_conditions }]
          end

          def master_variant_attributes(metadata)
            dims = metadata[:dimensions]
            {
              is_master: true,
              weight: dims[:weight],
              height: dims[:height],
              width: dims[:width],
              depth: dims[:depth]
            }
          end
        end
      end
    end
  end
end
