class UpdateSupportCaseDataToVersion14 < ActiveRecord::Migration[7.1]
  def change
    update_view :support_case_data, version: 14, revert_to_version: 13
  end
end
