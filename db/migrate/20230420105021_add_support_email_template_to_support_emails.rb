class AddSupportEmailTemplateToSupportEmails < ActiveRecord::Migration[7.0]
  def change
    add_reference :support_emails, :template, foreign_key: { to_table: :support_email_templates }, type: :uuid
  end
end
