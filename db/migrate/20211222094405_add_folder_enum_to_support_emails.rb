class AddFolderEnumToSupportEmails < ActiveRecord::Migration[6.1]
  def change
    add_column :support_emails, :folder, :integer
  end
end
