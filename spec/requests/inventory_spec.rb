RSpec.describe 'Inventory update', type: :request do
  subject(:update) do
    post '/api/v1/inventory/csv/fake', params: content, headers: { 'X-Spree-Token': token }
    response
  end

  let(:json) { JSON.parse(update.body, symbolize_names: true) }
  let(:token) {}
  let(:content) { '' }

  context 'when user is unauthorized' do
    it { is_expected.to have_http_status(:unauthorized) }
    it { expect(update.body).to match('You must specify an API key') }
  end

  context 'when user is authorized', run_jobs: true do
    let(:admin) { create :admin_user, spree_api_key: 'secure' }
    let(:token) { admin.spree_api_key }

    context 'when has content' do
      let(:content) { File.read(File.join(Dir.pwd, 'spec/fixtures', 'inventory.csv')) }

      it { is_expected.to have_http_status(:ok) }
      it { expect(json).to include(status: 'completed') }
      it { expect { update }.to change(Spree::Product, :count).by(5) }
      it { expect { update }.to change(Spree::Variant, :count).by(10) }
      it { expect { update }.to change(Spree::Image, :count).by(0) }

      describe 'after update' do
        before { update }

        it { expect(Spree::Variant.last.total_on_hand).to eq(1) }
      end
    end
  end
end
