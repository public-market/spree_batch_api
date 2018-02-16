module Spree
  module Api
    module V1
      class OrdersController < Spree::Api::BaseController
        def fetch
          authorize! :index, Order

          @from = Time.at(fetch_params[:from_timestamp].to_i)
          @orders = Order.complete
                         .where(payment_state: :paid)
                         .where('updated_at > ?', @from)
                         .to_a

          respond_with(@orders)
        end

        def update_shipments
          authorize! :create, Shipment

          @success = 0
          @failures = {}

          orders_params.each_with_index do |order, index|
            begin
              options = order_update_params(order).merge(user: current_api_user)
              UpdateOrderShipmentAction.new(options).call
              @success += 1
            rescue => e
              @failures[index] = e.message.gsub('Spree::', '')
            end
          end
        end

        private

        def fetch_params
          params.permit(:from_timestamp)
        end

        def order_update_params(order)
          order.permit([permitted_order_attributes]).to_h
        end

        def orders_params
          params.require(:orders)
        end

        def permitted_order_attributes
          %i[number action]
        end
      end
    end
  end
end
