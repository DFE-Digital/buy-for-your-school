class AddSupportEmailAttachmentsIndexes < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :support_email_attachments, :email_id, algorithm: :concurrently
  end
end
