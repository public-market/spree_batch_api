Spree::AppConfiguration.class_eval do
  preference :product_metadata_provider, :string, default: 'Spree::Inventory::Providers::FakeMetadataProvider'
end
