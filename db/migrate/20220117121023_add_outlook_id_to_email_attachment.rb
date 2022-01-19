class AddOutlookIdToEmailAttachment < ActiveRecord::Migration[6.1]
  def change
    add_column :support_email_attachments, :outlook_id, :string, index: true
  end
end
