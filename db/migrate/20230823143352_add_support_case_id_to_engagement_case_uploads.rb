class AddSupportCaseIdToEngagementCaseUploads < ActiveRecord::Migration[7.0]
  def change
    add_column :engagement_case_uploads, :support_case_id, :uuid
  end
end
