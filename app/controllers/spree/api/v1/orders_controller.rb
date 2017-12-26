module Spree
  module Api
    module V1
      class OrdersController < Spree::Api::BaseController
        def fetch
          authorize! :index, Order

          @from = Time.at(fetch_params[:from_timestamp].to_i)
          @orders = Order.complete.where('updated_at > ?', @from).to_a

          respond_with(@orders)
        end

        private

        def fetch_params
          params.permit(:from_timestamp)
        end
      end
    end
  end
end
