RSpec.configure do |config|
  config.before do
    %w[Books].each do |type|
      allow_any_instance_of("Spree::Inventory::Providers::#{type}::MetadataProvider".constantize).to receive(:images).and_return([])
    end
  end

  config.before(:each, images: true) do
    %w[Books].each do |type|
      allow_any_instance_of("Spree::Inventory::Providers::#{type}::MetadataProvider".constantize).to receive(:images).and_call_original
    end
  end
end
