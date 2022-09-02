class ChangeSupportEmailsInReplyToId < ActiveRecord::Migration[7.0]
  def up
    remove_column :support_emails, :replying_to_id
    add_column :support_emails, :in_reply_to_id, :string
    add_index :support_emails, :in_reply_to_id
  end

  def down
    add_column :support_emails, :replying_to_id, :uuid
    add_index :support_emails, :replying_to_id
    remove_column :support_emails, :in_reply_to_id
  end
end
