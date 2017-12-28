module Spree
  module Api
    module V1
      class InventoryController < Spree::Api::BaseController
        def update
          authorize! :create, Product

          @success = 0
          @failures = {}
          inventory_params.each_with_index do |product, index|
            begin
              options = {
                product_attrs: product_params(product),
                master_attrs: master_params(product),
                option_types_attrs: option_types_params(product),
                property_types_attrs: property_types_params(product),
                properties_attrs: properties_params(product),
                variants_attrs: variants_params(product)
              }
              UpdateInventoryItemAction.new(options).call
              @success += 1
            rescue => e
              @failures[index] = e.message
            end
          end
        end

        private

        def properties_params(product)
          product.permit(properties: {}).to_h[:properties]
        end

        def property_types_params(product)
          product.permit(property_types: permitted_property_attributes)
                 .to_h[:property_types]
        end

        def option_types_params(product)
          product.permit(option_types: [
                           permitted_option_type_attributes.push(
                             values: permitted_option_value_attributes
                           )
                         ])
                 .to_h[:option_types]
        end

        def variants_params(product)
          product.permit(variants: [variant_attributes]).to_h[:variants]
        end

        def master_params(product)
          product.permit(variant_attributes).to_h
        end

        def product_params(product)
          product.permit(permitted_product_attributes - [:options]).to_h
        end

        def variant_attributes
          permitted_variant_attributes.push(images: [permitted_image_attributes], options: {})
        end

        def permitted_image_attributes
          %i[url position title type height width]
        end

        def inventory_params
          params.require(:products)
        end
      end
    end
  end
end
