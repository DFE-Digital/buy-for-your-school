class CreateSupportEmails < ActiveRecord::Migration[6.1]
  def change
    create_table :support_emails, id: :uuid do |t|
      t.string :subject
      t.text :body
      t.jsonb :sender
      t.jsonb :recipients
      t.string :conversation_id
      t.uuid :case_id
      t.datetime :sent_at
      t.datetime :received_at
      t.datetime :read_at

      t.timestamps
    end
  end
end
