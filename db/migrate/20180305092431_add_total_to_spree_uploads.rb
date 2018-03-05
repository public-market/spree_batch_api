class AddTotalToSpreeUploads < ActiveRecord::Migration[5.1]
  def up
    add_column :spree_uploads, :total, :integer
    add_column :spree_uploads, :processed, :integer, default: 0
    remove_column :spree_uploads, :status
  end

  def down
    remove_column :spree_uploads, :total
    remove_column :spree_uploads, :processed
    add_column :spree_uploads, :status, :string
  end
end
