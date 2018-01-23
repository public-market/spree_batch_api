require 'spec_helper'

RSpec.describe Spree::UpdateInventoryItemAction, type: :action do
  subject(:product) { described_class.new(options).call }

  context 'when product is described well' do
    let(:images) { [] }

    let(:options) do
      {
        product_attrs: {
          name: 'Spree T-Shirt',
          description: 'Awesome Spree T-Shirt',
          price: '35',
          sku: 'SPREE-T-SHIRT',
          cost_price: '22.33'
        },
        option_types_attrs: [{
          name: 'condition', presentation: 'Condition', values: [
            { name: 'new', presentation: 'NEW' }
          ]
        }],
        property_types_attrs: [
          { name: 'author', presentation: 'Author' },
          { name: 'cover', presentation: 'Cover' }
        ],
        properties_attrs: {
          author: 'Jackson S.D',
          cover: 'Leather'
        },
        master_attrs: {
          sku: 'SPREE-T-SHIRT',
          options: { condition: 'NEW' },
          images: images
        },
        variants_attrs: [
          { sku: 'SPREE-T-SHIRT-S', price: '35', quantity: 5,
            options: { condition: 'NEW' }, images: images },
          { sku: 'SPREE-T-SHIRT-M', price: '37', quantity: 5,
            options: { condition: 'NEW' }},
          { sku: 'SPREE-T-SHIRT-XL', price: '40', quantity: 0,
            options: { condition: 'NEW' }}
        ]
      }
    end

    it { expect(product.valid?).to eq(true) }
    it { expect(product.id).not_to be_nil }
    it { expect(product.master).not_to be_nil }
    it { expect(product.option_types.count).to eq(1) }
    it { expect(product.option_types.first.name).to eq('condition') }
    it { expect(product.properties.count).to eq(2) }
    it { expect(product.images.count).to eq(0) }
    it { expect(product.variants.count).to eq(3) }
    it { expect(product.variants.first).to be_in_stock }
    it { expect(product.variants.first.option_values).not_to be_empty }
    it { expect(product.variants.last).not_to be_in_stock }
    it { expect(product.variants.first.images.count).to eq(0) }

    context 'with images' do
      let(:images) { [{ url: 'http://dummyimage.com/600x400/000/fff.jpg' }] }

      it 'upload images' do
        expect(product.images.count).to eq(1)
        expect(product.variants.first.images.count).to eq(1)
      end

      context 'when update' do
        subject(:updated_product) do
          product
          described_class.new(options).call
        end

        it 'do not duplicate entries' do
          expect(updated_product.valid?).to eq(true)
          expect(updated_product.properties.count).to eq(2)
          expect(updated_product.option_types.count).to eq(1)
          expect(updated_product.variants.count).to eq(3)
          expect(updated_product.images.count).to eq(1)
          expect(updated_product.variants.first.images.count).to eq(1)
        end
      end
    end
  end
end
