class UpdateSupportCaseDataToVersion9 < ActiveRecord::Migration[7.1]
  def change
    update_view :support_case_data, version: 9, revert_to_version: 8
  end
end
