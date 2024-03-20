class RenameSupportCaseSearchesEmailColumn < ActiveRecord::Migration[7.1]
  def change
    rename_column :support_case_searches, :email, :case_email
  end
end
