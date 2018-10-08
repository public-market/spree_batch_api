RSpec.describe Spree::Inventory::UploadFileAction, type: :action do
  subject(:upload) { described_class.call(format: file_format, file_path: file_path) }

  let(:file_format) { 'csv' }
  let(:file_path) { 'ean' }

  it { expect { upload }.to change(Spree::Upload, :count).by(1) }
  it { expect(upload.job_id).not_to be_nil }
  it { expect(upload.status).to eq('processing') }

  describe '#check_format' do
    let(:file_format) { 'csv1' }

    it { expect { upload }.not_to change(Spree::Upload, :count) }
    it { expect(upload[:errors].first).to include('"format"=>["must be one of') }
  end

  describe '#check_product_type' do
    it { expect { upload }.to change(Spree::Upload, :count).by(1) }

    context 'with not supported product type' do
      subject(:upload) { described_class.call(format: file_format, file_path: 'ean', product_type: product_type) }

      let(:product_type) { 'electronics' }

      it { expect { upload }.not_to change(Spree::Upload, :count) }
      it { expect(upload[:errors].first).to include('"product_type"=>["must be one of') }
    end
  end

  describe 'upload flow', run_jobs: true do
    let(:file_path) { File.join(Dir.pwd, 'spec/fixtures', 'inventory.update.csv') }
    let(:variant) { Spree::Variant.last }

    before { upload }

    it { expect(variant.upload_id).not_to be_nil }
    it { expect(variant.upload_index).to eq(1) }
  end
end
