class AddContactInfoToCase < ActiveRecord::Migration[6.1]
  def change
    change_table :support_cases, bulk: true do |t|
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :email, :string
      t.column :phone_number, :string
    end
  end
end
