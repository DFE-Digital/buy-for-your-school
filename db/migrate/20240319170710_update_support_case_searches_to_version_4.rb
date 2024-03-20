class UpdateSupportCaseSearchesToVersion4 < ActiveRecord::Migration[7.1]
  def change
    replace_view :support_case_searches, version: 4, revert_to_version: 3
  end
end
