class UpdateSupportCaseDataToVersion7 < ActiveRecord::Migration[7.0]
  def change
    update_view :support_case_data, version: 7, revert_to_version: 6
  end
end
