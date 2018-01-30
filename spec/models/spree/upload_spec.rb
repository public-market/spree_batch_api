require 'spec_helper'

RSpec.describe Spree::Upload, type: :model do
  describe 'after create' do
    let(:upload) { create :upload }

    it { expect(upload.status).to eq('processing') }
  end

  describe 'state machine' do
    let(:upload) { create :upload }

    before { upload.complete! }

    it { expect(upload.reload.status).to eq('completed') }
  end
end
