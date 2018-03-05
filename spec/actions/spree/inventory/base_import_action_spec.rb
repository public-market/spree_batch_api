require 'spec_helper'

RSpec.describe Spree::Inventory::BaseImportAction, type: :action, run_jobs: true do
  class FakeImportAction < Spree::Inventory::BaseImportAction
    param :items

    def map_items(&block)
      items.map.with_index(&block)
    end
  end

  before { FakeImportAction.call(items, upload: upload) }

  let(:upload) { create(:upload) }
  let(:item) do
    {
      ean: '9780979728303',
      sku: '08-F-002387',
      quantity: '1',
      price: '9.61',
      condition: 'Acceptable',
      notes: 'A book with obvious wear. May have some damage to the cover or binding but integrity is still intact. There might be writing in the margins, possibly underlining and highlighting of text, but no missing pages or anything that would compromise the legibility or understanding of the text.',
      seller: 'Goodwill Central Texas'
    }
  end

  context 'when no items' do
    let(:items) { [] }

    it { expect(upload.total).to eq(0) }
  end

  context 'when pass 1 item' do
    let(:items) { [item] }

    it { expect(upload.total).to eq(1) }
    it { expect(upload.reload.processed).to eq(1) }
    it { expect(Spree::Product.count).to eq(1) }
    it { expect(Spree::Variant.count).to eq(2) }
  end

  context 'when have error' do
    let(:items) { [{ ean: 'UNKNOWN' }] }

    it { expect(upload.total).to eq(1) }
    it { expect(upload.reload.processed).to eq(1) }
    it { expect(upload.reload.upload_errors.count).to eq(1) }
  end
end
