class CreateEngagementCaseUploads < ActiveRecord::Migration[7.0]
  def change
    create_table :engagement_case_uploads, id: :uuid do |t|
      t.integer :upload_status, default: 0
      t.string :filename
      t.integer :filesize
      t.string :upload_reference

      t.timestamps
    end
  end
end
