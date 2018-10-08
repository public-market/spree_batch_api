class AddUploadIdAndIndextoVariants < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_variants, :upload_id, :integer
    add_column :spree_variants, :upload_index, :integer
  end
end
