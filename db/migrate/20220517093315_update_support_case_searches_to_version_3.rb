class UpdateSupportCaseSearchesToVersion3 < ActiveRecord::Migration[6.1]
  def change
    update_view :support_case_searches, version: 3, revert_to_version: 2
  end
end
