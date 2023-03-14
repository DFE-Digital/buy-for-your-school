class AddAttachableToSuportCaseAttachments < ActiveRecord::Migration[7.0]
  def change
    change_table :support_case_attachments, bulk: true do |t|
      t.uuid :attachable_id
      t.string :attachable_type
      t.string :custom_name
    end
  end
end
