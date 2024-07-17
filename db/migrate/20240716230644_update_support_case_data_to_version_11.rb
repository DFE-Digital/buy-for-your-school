class UpdateSupportCaseDataToVersion11 < ActiveRecord::Migration[7.1]
  def change
    update_view :support_case_data, version: 11, revert_to_version: 10
  end
end
