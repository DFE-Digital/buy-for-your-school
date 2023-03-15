class AddToCcBccRecipientsToSupportEmails < ActiveRecord::Migration[7.0]
  def change
    change_table :support_emails, bulk: true do |t|
      t.column :to_recipients, :jsonb
      t.column :cc_recipients, :jsonb
      t.column :bcc_recipients, :jsonb
    end
  end
end
