class UpdateSupportCaseDataToVersion15 < ActiveRecord::Migration[7.2]
  def change
    update_view :support_case_data, version: 15, revert_to_version: 14
  end
end
