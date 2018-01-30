require 'spec_helper'

RSpec.describe Spree::Inventory::UploadFileAction, type: :action do
  subject(:upload) { described_class.call('csv', 'ean') }

  it { expect { upload }.to change(Spree::Upload, :count).by(1) }
  it { expect(upload.job_id).not_to be_nil }
end
