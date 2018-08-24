module Spree
  module Admin
    module ProductsControllerDecorator
      def inventory_uploads
        @uploads = @product.uploads
                           .order(:id)
                           .page(params[:page])
                           .per(params[:per_page] || 15)
      end
    end

    ProductsController.prepend(ProductsControllerDecorator)
  end
end
