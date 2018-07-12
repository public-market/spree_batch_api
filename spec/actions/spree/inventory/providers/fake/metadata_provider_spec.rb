RSpec.describe Spree::Inventory::Providers::Fake::MetadataProvider, type: :action do
  subject(:properties) { metadata[:properties] }

  let(:metadata) { described_class.call(isbn) }

  let(:isbn) { '787439929923' }

  it { expect(properties).to include(isbn: isbn) }
  it { expect(metadata[:title]).not_to be_empty }
  it { expect(metadata[:description]).not_to be_empty }
  it { expect(metadata[:dimensions]).not_to be_empty }
  it { expect(metadata[:price]).to be > 0 }
  it { expect(metadata[:taxons]).not_to be_empty }
end
