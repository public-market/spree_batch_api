require 'spec_helper'

RSpec.describe Spree::Upload, type: :model do
  describe 'after create' do
    let(:upload) { create :upload }

    it { expect(upload.status).to eq('processing') }
  end

  describe 'state machine' do
    let(:upload) { create :upload, total: 5 }

    it { expect(upload.reload.status).to eq('processing') }

    context 'when processed' do
      before { upload.update(processed: 5) }

      it { expect(upload.reload.status).to eq('completed') }
    end
  end
end
