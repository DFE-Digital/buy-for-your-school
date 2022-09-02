class AddUniqueBodyToSupportEmails < ActiveRecord::Migration[7.0]
  def change
    add_column :support_emails, :unique_body, :text
  end
end
