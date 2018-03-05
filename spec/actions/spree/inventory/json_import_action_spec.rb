require 'spec_helper'

describe Spree::Inventory::JsonImportAction, type: :action, run_jobs: true do
  subject(:call) { described_class.call(payload, upload: upload) }

  let(:upload) { create(:upload) }
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

    before do
      call
      upload.reload
    end

    it { expect(upload.total).to eq(1) }
    it { expect(upload.processed).to eq(1) }
    it { expect(upload.upload_errors.count).to eq(1) }
  end
end
