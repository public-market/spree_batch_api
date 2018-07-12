RSpec.configure do |config|
  config.before do
    allow_any_instance_of("Spree::Inventory::Providers::Fake::MetadataProvider".constantize).to receive(:images).and_return([])
  end

  config.before(:each, images: true) do
    allow_any_instance_of("Spree::Inventory::Providers::Fake::MetadataProvider".constantize).to receive(:images).and_call_original
  end
end
