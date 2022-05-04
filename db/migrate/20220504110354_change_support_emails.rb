class ChangeSupportEmails < ActiveRecord::Migration[6.1]
  def change
    rename_column :support_emails, :received_at, :outlook_received_at
    rename_column :support_emails, :read_at, :outlook_read_at
    rename_column :support_emails, :is_draft, :outlook_is_draft
    rename_column :support_emails, :has_attachments, :outlook_has_attachments

    remove_column :support_emails, :body_preview
  end
end
