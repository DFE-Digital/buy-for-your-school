class UpdateSupportCaseDataToVersion12 < ActiveRecord::Migration[7.1]
  def change
    update_view :support_case_data, version: 12, revert_to_version: 11
  end
end
