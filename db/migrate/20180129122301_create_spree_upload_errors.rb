class CreateSpreeUploadErrors < ActiveRecord::Migration[5.1]
  def change
    create_table :spree_upload_errors do |t|
      t.references :upload
      t.string :message

      t.timestamps
    end
  end
end
