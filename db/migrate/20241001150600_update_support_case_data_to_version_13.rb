class UpdateSupportCaseDataToVersion13 < ActiveRecord::Migration[7.1]
  def change
    update_view :support_case_data, version: 13, revert_to_version: 12
  end
end
