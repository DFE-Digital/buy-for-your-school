class AddIsReadToSupportEmails < ActiveRecord::Migration[6.1]
  def change
    rename_column :support_emails, :is_read, :outlook_is_read
    add_column :support_emails, :is_read, :boolean, default: false
  end
end
