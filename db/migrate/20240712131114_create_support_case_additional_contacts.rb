class CreateSupportCaseAdditionalContacts < ActiveRecord::Migration[7.1]
  def change
    create_table :support_case_additional_contacts, id: :uuid do |t|
      t.references :support_case, foreign_key: { to_table: :support_cases }, type: :uuid, null: false
      t.string :first_name
      t.string :last_name
      t.string :role, array: true, default: []
      t.string :phone_number
      t.string :extension_number
      t.string :email
      t.timestamps
    end
  end
end
