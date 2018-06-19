require 'spec_helper'

RSpec.describe Spree::Inventory::CSVImportAction, type: :action, run_jobs: true do
  subject(:call) { described_class.call(local_file, upload: upload, options: { product_type: 'books' }) }

  let(:upload) { create :upload }

  context 'when file is absent' do
    let(:local_file) { File.join(Dir.pwd, 'spec/fixtures', 'unknown.csv') }

    it { expect { call }.to raise_error(Spree::ImportError, 'CSV file is invalid') }
  end

  context 'when file is correct' do
    let(:local_file) { File.join(Dir.pwd, 'spec/fixtures', 'inventory.csv') }

    before { call }

    it { expect(Spree::Product.count).to eq(5) }
    it { expect(upload.total).to eq(5) }
    it { expect(upload.reload.processed).to eq(5) }
  end
end
