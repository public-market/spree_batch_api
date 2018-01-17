require 'spec_helper'

RSpec.describe 'Orders update shipments', type: :request do
  subject(:json) { JSON.parse(update.body, symbolize_names: true) }

  subject(:update) do
    post '/api/v1/orders/update_shipments', params: { token: token, orders: orders }
    response
  end

  let(:token) { '' }
  let(:orders) { [] }

  context 'when user is unauthorized' do
    it { is_expected.to have_http_status(:unauthorized) }
    it { expect(update.body).to match('You must specify an API key') }
  end

  context 'when user is authorized' do
    let(:admin) { create(:admin_user, spree_api_key: 'secure') }
    let(:token) { admin.spree_api_key }
    let(:order) { create(:order_ready_to_ship) }
    let(:orders) { [{ number: order.number, action: :ship }] }

    before { order.process_payments! }

    context 'when order is shipped' do
      it { is_expected.to have_http_status(:ok) }
      it { expect(json).to include(success: 1) }

      it 'changes shipment state' do
        expect {
          update
        }.to change { order.reload.shipment_state }.from('ready').to('shipped')
      end
    end
  end
end
