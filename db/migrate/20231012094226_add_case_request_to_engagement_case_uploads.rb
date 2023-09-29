class AddCaseRequestToEngagementCaseUploads < ActiveRecord::Migration[7.0]
  def change
    add_reference :engagement_case_uploads, :case_request, foreign_key: { to_table: :case_requests }, type: :uuid
  end
end
