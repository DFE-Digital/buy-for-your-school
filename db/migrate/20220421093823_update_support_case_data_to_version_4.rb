class UpdateSupportCaseDataToVersion4 < ActiveRecord::Migration[6.1]
  def change
    update_view :support_case_data, version: 4, revert_to_version: 3
  end
end
