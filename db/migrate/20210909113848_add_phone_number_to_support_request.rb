class AddPhoneNumberToSupportRequest < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :phone_number, :string
    add_column :support_requests, :phone_number, :string
  end
end
