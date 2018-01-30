class CreateSpreeUploads < ActiveRecord::Migration[5.1]
  def change
    create_table :spree_uploads do |t|
      t.string :job_id
      t.string :status

      t.timestamps
    end
  end
end
