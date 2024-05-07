class UpdateSupportCaseDataToVersion10 < ActiveRecord::Migration[7.1]
  def change
    update_view :support_case_data, version: 10, revert_to_version: 9
  end
end
