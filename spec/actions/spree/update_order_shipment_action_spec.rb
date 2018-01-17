require 'spec_helper'

RSpec.describe Spree::UpdateOrderShipmentAction, type: :action do
  subject(:updated_order) { described_class.new(options).call }

  let(:user) { create(:user) }

  context 'when shipment is in pending state' do
    let(:order) { create(:completed_order_with_totals, payment_state: 'paid', shipment_state: 'pending') }

    describe 'shipment is ready' do
      let(:options) { { number: order.number, action: 'ready' } }

      it 'changes shipment state' do
        expect {
          updated_order
        }.to change { order.reload.shipment_state }.from('pending').to('ready')
      end
    end
  end

  context 'when shipment is paid' do
    let(:order) { create(:order_ready_to_ship) }

    context 'when shipment is canceled' do
      let(:options) { { number: order.number, action: 'cancel', user: user } }

      it { expect(updated_order.state).to eq('canceled') }

      it 'changes shipment state' do
        expect {
          updated_order
        }.to change { order.reload.shipment_state }.from('ready').to('canceled')
      end
    end
  end

  context 'when shipment is shipped' do
    let(:order) { create(:order_ready_to_ship) }
    let(:options) { { number: order.number, action: 'ship' } }

    it { expect(updated_order.shipment_state).to eq('shipped') }
  end
end
