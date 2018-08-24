class CreateSpreeProductUploads < ActiveRecord::Migration[5.2]
  def change
    create_table :spree_product_uploads do |t|
      t.references :product
      t.references :upload
      t.timestamps null: false
    end
  end
end
