require 'spec_helper'

RSpec.describe Spree::Inventory::Providers::FakeMetadataProvider, type: :action do
  subject(:metadata) { described_class.call(isbn) }
  subject(:properties) { metadata[:properties] }

  let(:isbn) { '787439929923' }

  it { expect(properties).to include(isbn: isbn) }
  it { expect(metadata[:title]).not_to be_empty }
  it { expect(metadata[:description]).not_to be_empty }
  it { expect(metadata[:dimensions]).not_to be_empty }
  it { expect(metadata[:price]).to be > 0 }
end
