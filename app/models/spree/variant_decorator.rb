module Spree
  module VariantDecorator
    def build_options(options)
      options.each do |option|
        build_option_value(option[:name], option[:value])
      end
    end

    # https://github.com/spree/spree/blob/master/core/app/models/spree/variant.rb#L160
    def build_option_value(opt_name, opt_value)
      # no option values on master
      return if is_master

      option_type = Spree::OptionType.where(name: opt_name).first_or_initialize do |o|
        o.presentation = opt_name
        o.save!
      end

      current_value = option_values.detect { |o| o.option_type.name == opt_name }

      if current_value.nil?
        # then we have to check to make sure that the product has the option type
        product.option_types << option_type unless product.option_types.include?(option_type)
      else
        return if current_value.name == opt_value
        option_values.delete(current_value)
      end

      option_value = Spree::OptionValue.where(option_type_id: option_type.id, name: opt_value).first_or_initialize do |o|
        o.presentation = opt_value
        o.save!
      end

      option_values << option_value
    end
  end

  Variant.prepend(VariantDecorator)
end
