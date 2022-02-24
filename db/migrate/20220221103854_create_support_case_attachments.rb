class CreateSupportCaseAttachments < ActiveRecord::Migration[6.1]
  def change
    create_table :support_case_attachments, id: :uuid do |t|
      t.belongs_to :support_case, foreign_key: true, type: :uuid
      t.belongs_to :support_email_attachment, foreign_key: true, type: :uuid
      t.string :name
      t.text :description
      t.timestamps
    end
  end
end
