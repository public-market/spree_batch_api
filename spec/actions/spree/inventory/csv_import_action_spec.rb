require 'spec_helper'

RSpec.describe Spree::Inventory::CSVImportAction, type: :action do
  subject(:call) { described_class.call(status_worker, local_file) }

  context 'when file is absent' do
    let(:status_worker) { instance_spy('StatusWorker') }
    let(:local_file) { File.join(Dir.pwd, 'spec/fixtures', 'unknown.csv') }

    it { expect { call }.to raise_error(Spree::ImportError, 'CSV file is invalid') }
  end

  context 'when file is correct' do
    let(:status_worker) { instance_spy('StatusWorker') }
    let(:local_file) { File.join(Dir.pwd, 'spec/fixtures', 'inventory.csv') }

    before { call }

    it { expect(Spree::Product.count).to eq(5) }
    it { expect(status_worker).to have_received(:at).exactly(5).times }
    it { expect(status_worker).to have_received(:total).with(5) }
  end
end
