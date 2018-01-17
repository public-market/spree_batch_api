module Spree
  class UpdateOrderShipmentAction
    attr_accessor :options

    def initialize(options)
      self.options = options.deep_dup
    end

    def call
      @order = Order.find_by!(number: options[:number])

      case options[:action]
      when 'cancel'
        cancel_order
      when 'ready'
        set_ready
      when 'ship'
        ship_order
      end

      @order
    end

    private

    def cancel_order
      @order.canceled_by(options[:user])
    end

    def set_ready
      @order.shipments.each do |shipment|
        break if shipment.ready?
        shipment.ready!
      end

      # call manually because it's not called in spree on transition to ready
      Spree::OrderUpdater.new(@order).update_shipment_state
      @order.save!
    end

    def ship_order
      @order.shipments.each do |shipment|
        shipment.ship! unless shipment.shipped?
      end
    end
  end
end
