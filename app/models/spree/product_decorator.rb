module Spree
  module ProductDecorator
    def self.prepended(base)
      base.has_many :product_uploads, class_name: 'Spree::ProductUpload', dependent: :destroy
      base.has_many :uploads, through: :product_uploads, class_name: 'Spree::Upload', source: :upload
    end
  end

  Product.prepend(ProductDecorator)
end
