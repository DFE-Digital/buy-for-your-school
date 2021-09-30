class AddContactDetailsToUser < ActiveRecord::Migration[6.1]
  def change
    change_table :users do |t|
      t.string :phone_number
    end
  end
end
