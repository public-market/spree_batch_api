module Spree
  class ProductUpload < Spree::Base
    belongs_to :product, class_name: 'Spree::Product'
    belongs_to :upload, class_name: 'Spree::Upload'
  end
end
