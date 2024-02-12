class UpdateSupportCaseDataToVersion8 < ActiveRecord::Migration[7.1]
  def change
    update_view :support_case_data, version: 8, revert_to_version: 7
  end
end
