describe Spree::UploadInventoryWorker, type: :worker, run_jobs: true do
  subject(:perform) { described_class.perform_async(upload.id.to_s) }

  let(:upload_opts) { { format: format, file_path: filename, product_type: :fake } }
  let(:upload) { create(:upload, metadata: upload_opts) }

  context 'when upload csv' do
    let(:format) { 'csv' }
    let(:filename) { File.join(Dir.pwd, 'spec/fixtures', 'inventory.csv') }

    it { is_expected.not_to be_nil }

    describe 'perform worker' do
      before { perform }

      it { expect(Spree::Product.count).to eq(5) }
      it { expect(Spree::Variant.count).to eq(10) }
      it { expect(upload.reload.total).to eq(5) }
      it { expect(upload.reload.processed).to eq(5) }
    end
  end
end
