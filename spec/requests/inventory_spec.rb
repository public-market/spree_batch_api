require 'spec_helper'

RSpec.describe 'Inventory update', type: :request do
  subject(:json) { JSON.parse(update.body, symbolize_names: true) }
  subject(:update) do
    post '/api/v1/inventory', params: { token: token, products: products }
    response
  end

  let(:token){}
  let(:products){}

  context 'when user is unauthorized' do
    it { is_expected.to have_http_status(:unauthorized) }
    it { expect(update.body).to match('You must specify an API key') }
  end

  context 'when user is authorized' do
    let(:admin) { create :admin_user, spree_api_key: 'secure' }
    let(:token) { admin.spree_api_key }

    context 'when no content' do
      it { is_expected.to have_http_status(:unprocessable_entity) }
    end

    context 'when has products' do
      let(:products) do
        [{
          name: 'The Other Product',
          price: 19.99
        }]
      end

      it { is_expected.to have_http_status(:ok) }
      it { expect(json).to include(success: 1) }
    end
  end
end
