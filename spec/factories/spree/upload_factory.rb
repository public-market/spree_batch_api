FactoryBot.define do
  factory :upload, class: Spree::Upload do
    metadata(
      file_path: './spec/fixtures/inventory.csv',
      format: 'csv',
      product_type: 'fake'
    )
  end
end
