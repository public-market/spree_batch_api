module Spree
  class UpdateInventoryItemAction
    attr_accessor :options

    def initialize(options)
      self.options = options.deep_dup
    end

    def call
      product = nil

      Product.transaction do
        product = process_product(options[:product_attrs])
        process_option_types(product, options[:option_types_attrs])
        process_properties(product,
                           options[:property_types_attrs],
                           options[:properties_attrs])
        process_variant(product.master, options[:master_attrs])
        process_variants(product, options[:variants_attrs])
      end

      product
    end

    private

    def process_product(product_attrs)
      variant = Variant.where(is_master: true, sku: product_attrs[:sku]).first
      product = variant.try(:product) || new_product
      product.update_attributes(product_attrs)
      product
    end

    def new_product
      StockLocation.first_or_create(name: 'default')

      Product.new(
        shipping_category: ShippingCategory.first_or_create(name: 'Default')
      )
    end

    def process_option_types(product, option_types)
      return if option_types.blank?

      option_types.each do |option_type_attrs|
        option_type_attrs[:option_values_attributes] = option_type_attrs.delete(:values)
        option_type = OptionType.where(name: option_type_attrs[:name])
                                .first_or_create(option_type_attrs)

        product.option_types << option_type unless product.option_types
                                                          .include?(option_type)
      end
    end

    def process_properties(product, property_types, properties)
      return if property_types.blank? || properties.blank?

      property_types.each do |property_attrs|
        property_name = property_attrs[:name]
        property = Property.where(name: property_name).first_or_create(property_attrs)

        ProductProperty.where(product: product, property: property).first_or_initialize do |pp|
          pp.value = properties[property_name.to_sym]
          pp.save! if pp.value.present?
        end
      end
    end

    def process_variants(product, variants)
      return if variants.blank?

      variants.each do |variant_attrs|
        variant = Variant.unscoped
                         .where(sku: variant_attrs[:sku], product: product)
                         .first_or_initialize
        process_variant(variant, variant_attrs)
      end
    end

    def process_variant(variant, variant_attrs)
      quantity = variant_attrs.delete(:quantity)
      images = variant_attrs.delete(:images)
      variant_attrs[:options] = variant_attrs[:options].map do |k, v|
        { name: k.to_s, value: v }
      end

      variant.update_attributes!(variant_attrs)

      process_quantity(variant, quantity)
      process_images(variant, images)
    end

    def process_quantity(variant, quantity)
      return unless quantity.present?

      stock_item = variant.stock_items.first
      stock_item.set_count_on_hand(quantity)
    end

    def process_images(variant, images)
      return if images.blank?
      existing = variant.images.pluck(:attachment_file_name)
      images.each do |image_attrs|
        next if existing.any? { |name| image_attrs[:url].end_with?(name) }

        variant.images.create!(
          alt: image_attrs[:title],
          attachment: URI.parse(image_attrs[:url]),
          position: image_attrs[:position]
        )
      end
    end
  end
end
