require 'spec_helper'

RSpec.describe Spree::UpdateOrderShipmentAction, type: :action do
  subject(:updated_order) { described_class.new(options).call }

  let(:user) { create :user }

  context 'when shipment is paid' do
    let(:order) { create :completed_order_with_store_credit_payment }

    before { order.process_payments! }

    context 'when shipment is ready' do
      let(:options) { { number: order.number, action: 'ready' } }
      it { expect(updated_order.shipment_state).to eq('ready') }
    end

    context 'when shipment is canceled' do
      let(:options) { { number: order.number, action: 'cancel', user: user } }
      it { expect(updated_order.shipment_state).to eq('canceled') }
      it { expect(updated_order.state).to eq('canceled') }
    end
  end

  context 'when shipment is shipped' do
    let(:order) { create :order_ready_to_ship }
    let(:options) { { number: order.number, action: 'ship' } }

    it { expect(updated_order.shipment_state).to eq('shipped') }
  end


end
