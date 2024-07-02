class AddSupportEmailsIndexes < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :support_emails, %i[ticket_id ticket_type], algorithm: :concurrently
    add_index :support_emails, %i[outlook_conversation_id sent_at], order: { sent_at: :desc }, algorithm: :concurrently
    add_index :support_emails, %i[outlook_conversation_id ticket_id ticket_type], algorithm: :concurrently
  end
end
