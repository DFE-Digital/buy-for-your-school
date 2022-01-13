class AddIsInlineToSupportEmailAttachments < ActiveRecord::Migration[6.1]
  def change
    add_column :support_email_attachments, :is_inline, :boolean, default: false
    add_column :support_email_attachments, :content_id, :string
  end
end
