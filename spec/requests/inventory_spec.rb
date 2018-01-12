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
      let(:products) { [JSON.load(File.new('spec/fixtures/product.json'))] }

      it { is_expected.to have_http_status(:ok) }
      it { expect(json).to include(success: 1) }
      it { expect { update }.to change(Spree::Product, :count).by(1) }
      it { expect { update }.to change(Spree::Variant, :count).by(2) }
      it { expect { update }.to change(Spree::Image, :count).by(2) }

      describe 'after update' do
        before { update }
        it { expect(Spree::Variant.last.total_on_hand).to eq(1) }
      end
    end
  end
end
