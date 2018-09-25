RSpec.describe Spree::Inventory::Providers::DefaultVariantProvider, type: :action do
  subject(:variant) { described_class.call(item_json) }

  describe 'validation' do
    let(:item_json) do
      {
        ean: 'isbn',
        quantity: nil,
        price: nil
      }
    end

    it 'raises exception' do
      expect { variant }.to raise_error(Spree::ImportError).with_message(include(':sku=>["is missing"]'))
      expect { variant }.to raise_error(Spree::ImportError).with_message(include(':quantity=>["must be filled"]'))
      expect { variant }.to raise_error(Spree::ImportError).with_message(include(':price=>["must be filled"]'))
    end
  end
end
