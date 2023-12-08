class AddIsDraftToSupportEmails < ActiveRecord::Migration[7.1]
  def change
    add_column :support_emails, :is_draft, :boolean, default: false
  end
end
