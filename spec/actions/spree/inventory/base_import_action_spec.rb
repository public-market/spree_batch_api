require 'spec_helper'

RSpec.describe Spree::Inventory::BaseImportAction, type: :action do
  class FakeImportAction < Spree::Inventory::BaseImportAction
    param :items

    def map_items(&block)
      items.map.with_index(&block)
    end
  end

  before { FakeImportAction.call(status_worker, items) }

  let(:status_worker) { instance_spy('StatusWorker') }
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

    it { expect(status_worker).not_to have_received(:at) }
  end

  context 'when pass 1 item' do
    let(:items) { [item] }

    it { expect(status_worker).to have_received(:at).once }
    it { expect(Spree::Product.count).to eq(1) }
    it { expect(Spree::Variant.count).to eq(2) }
  end

  context 'when have error' do
    let(:items) { [{ ean: 'UNKNOWN' }] }

    it { expect(status_worker).to have_received(:at).once }
    it { expect(status_worker).to have_received(:catch_error).once }
  end
end
