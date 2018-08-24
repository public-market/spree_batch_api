FactoryBot.define do
  factory :upload, class: Spree::Upload do
    metadata do
      {
        file_path: './spec/fixtures/inventory.csv',
        format: 'csv',
        product_type: 'fake'
      }
    end
  end
end
