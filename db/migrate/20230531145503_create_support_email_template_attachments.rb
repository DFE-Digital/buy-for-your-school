class CreateSupportEmailTemplateAttachments < ActiveRecord::Migration[7.0]
  def change
    create_table :support_email_template_attachments, id: :uuid do |t|
      t.string :file_type
      t.string :file_name
      t.bigint :file_size
      t.references :template, foreign_key: { to_table: :support_email_templates }, type: :uuid

      t.timestamps
    end
  end
end
