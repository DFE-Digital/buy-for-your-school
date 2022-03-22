class UpdateSupportCaseSearchesToVersion2 < ActiveRecord::Migration[6.1]
  def change
    update_view :support_case_searches, version: 2, revert_to_version: 1
  end
end
