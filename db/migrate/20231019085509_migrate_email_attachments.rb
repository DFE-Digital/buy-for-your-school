class MigrateEmailAttachments < ActiveRecord::Migration[7.0]
  def up
    ActiveStorage::Attachment.where(record_type: "Support::EmailAttachment").update(record_type: "EmailAttachment")
  end

  def down
    ActiveStorage::Attachment.where(record_type: "EmailAttachment").update(record_type: "Support::EmailAttachment")
  end
end
