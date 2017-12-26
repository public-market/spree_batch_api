require 'spec_helper'

RSpec.describe 'Inventory update', type: :request do
  let(:token) { '' }
  before { post '/api/v1/inventory', params: { token: token } }

  context 'when user is unauthorized' do
    it { expect(response).to have_http_status(:unauthorized) }
    it { expect(response.body).to match('You must specify an API key') }
  end

  context 'when user is authorized' do
    let(:admin) { create :admin_user, spree_api_key: 'secure' }
    let(:token) { admin.spree_api_key }

    context 'when no content' do
      it { expect(response).to have_http_status(:no_content) }
    end
  end
end
