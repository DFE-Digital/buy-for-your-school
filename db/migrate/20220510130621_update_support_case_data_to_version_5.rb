class UpdateSupportCaseDataToVersion5 < ActiveRecord::Migration[6.1]
  def change
    update_view :support_case_data, version: 5, revert_to_version: 4
  end
end
