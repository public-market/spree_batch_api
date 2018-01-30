require 'spec_helper'

describe Spree::Inventory::JsonImportAction, type: :action do
  subject(:call) { described_class.call(nil, payload) }

  let(:payload) { nil }

  it { expect { call }.to raise_error(Spree::ImportError, 'Empty JSON payload') }

  context 'when json is invalid' do
    let(:payload) { '{ "invalid_json": }' }

    it { expect { call }.to raise_error(Spree::ImportError, 'Payload JSON is invalid') }
  end

  context 'when json is array' do
    let(:payload) { '[{ "x": 1 }]' }

    it { expect { call }.to raise_error(Spree::ImportError, 'Root of JSON should be an object') }
  end

  context 'when json have no items' do
    let(:payload) { '{ "x": 1 }' }

    it { expect { call }.to raise_error(Spree::ImportError, 'JSON schema is invalid: [items] required') }
  end

  context 'when json have wrong items' do
    let(:payload) { '{ "items": [{"id": "some"}] }' }

    it {
      expect { call }.to raise_error do |error|
        expect(error).to be_a(Spree::ImportError)
        expect(error.message).to match('Item 0 invalid')
        expect(error.object).to include(:sku)
      end
    }
  end
end
