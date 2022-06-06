class AddReplyingToIdToSupportEmails < ActiveRecord::Migration[6.1]
  def change
    add_reference :support_emails, :replying_to, null: true, foreign_key: { to_table: :support_emails }, type: :uuid
    add_column :support_emails, :case_reference_from_headers, :string
    add_column :support_emails, :outlook_internet_message_id, :string
  end
end
