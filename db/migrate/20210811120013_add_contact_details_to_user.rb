class AddContactDetailsToUser < ActiveRecord::Migration[6.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :full_name
      t.string :email_address
      t.string :phone_number
      t.jsonb :contact_preferences, default: {}
    end
  end
end
