class AddCustomNameAndDescriptionToSupportEmailAttachments < ActiveRecord::Migration[7.0]
  def change
    change_table :support_email_attachments, bulk: true do |t|
      t.column :custom_name, :string
      t.column :description, :string
      t.column :hidden, :boolean, default: false
    end

    change_table :support_case_attachments, bulk: true do |t|
      t.column :hidden, :boolean, default: false
    end

    change_table :energy_bills, bulk: true do |t|
      t.column :hidden, :boolean, default: false
    end
  end
end
