class CreateSupportEmailAttachments < ActiveRecord::Migration[6.1]
  def change
    create_table :support_email_attachments, id: :uuid do |t|
      t.string :file_type
      t.string :file_name
      t.bigint :file_size
      t.uuid   :email_id

      t.timestamps
    end
  end
end
