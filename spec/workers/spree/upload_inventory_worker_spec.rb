require 'spec_helper'

describe Spree::UploadInventoryWorker, type: :worker do
  subject(:perform) { described_class.perform_async(upload.id.to_s, format, filename) }

  let(:upload) { create(:upload) }

  context 'when upload csv' do
    let(:format) { 'csv' }
    let(:filename) { File.join(Dir.pwd, 'spec/fixtures', 'inventory.csv') }

    it { is_expected.not_to be_nil }

    it 'enqueues worker' do
      perform
      expect(described_class).to have_enqueued_sidekiq_job(upload.id.to_s, 'csv', filename)
    end

    describe 'perform worker', run_jobs: true do
      it { expect { perform }.to change(Spree::Product, :count).by(5) }
      it { expect { perform }.to change(Spree::Variant, :count).by(10) }
      it { expect(Sidekiq::Status.total(perform)).to eq(5) }
      it { expect(Sidekiq::Status.at(perform)).to eq(5) }
    end
  end
end
