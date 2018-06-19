require 'spec_helper'

describe Spree::UploadInventoryWorker, type: :worker do
  subject(:perform) { described_class.perform_async(upload.id.to_s, format, filename, product_type: product_type) }

  let(:upload) { create(:upload) }
  let(:product_type) { :books }

  context 'when upload csv' do
    let(:format) { 'csv' }
    let(:filename) { File.join(Dir.pwd, 'spec/fixtures', 'inventory.csv') }

    it { is_expected.not_to be_nil }

    it 'enqueues worker' do
      perform
      expect(described_class).to have_enqueued_sidekiq_job(upload.id.to_s, 'csv', filename, 'product_type' => 'books')
    end

    describe 'perform worker', run_jobs: true do
      before { perform }

      it { expect(Spree::Product.count).to eq(5) }
      it { expect(Spree::Variant.count).to eq(10) }
      it { expect(upload.reload.total).to eq(5) }
      it { expect(upload.reload.processed).to eq(5) }
    end
  end

  context 'when product type is not specified', run_jobs: true do
    let(:product_type) { nil }
    let(:format) { 'csv' }
    let(:filename) { File.join(Dir.pwd, 'spec/fixtures', 'inventory.csv') }

    before { perform }

    it { expect(Spree::Product.count).to eq(0) }
    it { expect(upload.reload.upload_errors.count).to eq(5) }
  end
end
