RSpec.describe Spree::Inventory::Providers::DefaultVariantProvider, type: :action do
  subject(:variant) { described_class.call(item_json, options: options) }

  let(:options) { {} }

  describe 'validation' do
    let(:item_json) { { ean: 'isbn' } }

    it { expect { variant }.to raise_error(Spree::ImportError).with_message(include(":sku=>[\"is missing\"]")) }
  end
end