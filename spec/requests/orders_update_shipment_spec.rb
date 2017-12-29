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
    let(:admin) { create :admin_user, spree_api_key: 'secure' }
    let(:token) { admin.spree_api_key }
    let(:order) { create :completed_order_with_store_credit_payment }
    let(:orders) { [{ number: order.number, action: :ready }] }

    before { order.process_payments! }

    context 'when order is ready' do
      it { is_expected.to have_http_status(:ok) }
      it { expect(order.reload.shipment_state).to eq('ready') }
      it { expect(json).to include(success: 1) }
    end
  end
end
