require 'spec_helper'

RSpec.describe Spree::Inventory::UploadFileAction, type: :action do
  subject(:upload) { described_class.call(file_format, 'ean') }

  let(:file_format) { 'csv' }

  it { expect { upload }.to change(Spree::Upload, :count).by(1) }
  it { expect(upload.job_id).not_to be_nil }
  it { expect(upload.status).to eq('processing') }

  describe '#check_format' do
    let(:file_format) { 'csv1' }

    it { expect { upload }.not_to change(Spree::Upload, :count) }
    it { expect(upload[:errors]).to eq(I18n.t('actions.spree.inventory.upload_file_action.unsupported_format')) }
  end
end
