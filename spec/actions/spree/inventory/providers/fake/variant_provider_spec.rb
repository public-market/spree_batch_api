RSpec.describe Spree::Inventory::Providers::Fake::VariantProvider, type: :action do
  subject(:variant) { described_class.call(item_json, options: options) }

  let(:options) { {} }

  describe 'validation' do
    let(:item_json) { { sku: 'sku' } }

    it { expect { variant }.to raise_error(Spree::ImportError).with_message(include(':ean=>["is missing"]')) }
  end

  describe 'creation' do
    let(:item_json) do
      {
        ean: isbn,
        sku: '08-F-002387',
        quantity: '1',
        price: '9.61',
        condition: 'Acceptable',
        notes: 'A book with obvious wear. May have some damage to the cover or binding but integrity is still intact. There might be writing in the margins, possibly underlining and highlighting of text, but no missing pages or anything that would compromise the legibility or understanding of the text.',
        seller: 'Goodwill Central Texas'
      }
    end

    let(:isbn) { '9780979728303' }

    context 'with unknown isbn' do
      let(:isbn) { Spree::Inventory::Providers::Fake::MetadataProvider::UNKNOWN_ISBN }

      it { expect { variant }.to raise_error(Spree::ImportError, 'Metadata for given identifier not found') }
    end

    context 'with known isbn' do
      subject(:product) { variant.product }

      it { expect(product).not_to be_nil }
      it { expect(product).to be_persisted }
      it { expect(product.width).not_to be_nil }
      it { expect(product.available_on).not_to be_nil }
      it { expect(product.description).not_to be_nil }
      it { expect(product.properties.count).to eq(7) }
      it { expect(product.option_types.count).to eq(1) }
      it { expect(product.variants.count).to eq(1) }
      it { expect(product.taxons.count).to eq(1) }
      it { expect(product.taxons.first.taxonomy.name).to eq('Categories') }

      it { expect(variant).not_to be_nil }
      it { expect(variant).not_to eq(product.master) }
      it { expect(variant.sku).to eq(item_json[:sku]) }
      it { expect(variant.option_value('condition')).to eq(item_json[:condition]) }
      it { expect(variant.price).to eq(item_json[:price]) }
      it { expect(variant.cost_price).to eq(item_json[:price]) }
      it { expect(variant.total_on_hand).to eq(1) }

      context 'with variant notes' do
        Spree::Variant.class_eval do
          attr_accessor :notes
        end

        it { expect(variant.notes).to eq(item_json[:notes]) }
      end

      context 'with taxonomy option' do
        let(:options) { { taxonomy: 'Books' } }

        it { expect(product.taxons.first.taxonomy.name).to eq('Books') }
      end
    end

    context 'when variant already exists' do
      let(:isbn) { '9780979728303' }

      before do
        described_class.call(item_json)
        item_json[:quantity] = 2
        item_json[:price] = 10.50
      end

      it { expect { variant }.to change(Spree::Product, :count).by(0) }
      it { expect(variant.product.variants.count).to eq(1) }
      it { expect(variant.price).to eq(10.5) }
      it { expect(variant.cost_price).to eq(10.5) }
      it { expect(variant.total_on_hand).to eq(2) }
    end

    describe 'saving upload id' do
      let(:upload) { create(:upload) }
      let(:options) { { upload_id: upload.id } }

      it { expect(variant.product.uploads.first).to eq upload }
    end
  end
end
