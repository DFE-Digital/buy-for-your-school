class UpdateSupportCaseDataToVersion6 < ActiveRecord::Migration[6.1]
  def change
    update_view :support_case_data, version: 6, revert_to_version: 5
  end
end
