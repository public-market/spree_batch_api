class CreateUploadItems < ActiveRecord::Migration[5.2]
  def change
    create_table :spree_upload_items do |t|
      t.references :upload
      t.integer :index
      t.json :item_json, null: false, default: {}
      t.json :options, null: false, default: {}
      t.timestamps null: false
    end
  end
end
