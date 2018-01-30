require 'spec_helper'

RSpec.describe Spree::Inventory::Providers::FakeMetadataProvider, type: :action do
  subject(:metadata) { described_class.call(isbn) }

  let(:isbn) { '787439929923' }

  it { is_expected.to include(isbn: isbn) }
  it { expect(metadata[:author]).not_to be_empty }
  it { expect(metadata[:description]).not_to be_empty }
end
