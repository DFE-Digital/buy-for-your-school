class CreateOtpUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :otp_users, id: :uuid do |t|
      t.string :email
      t.string :otp_secret_key
      t.integer :last_otp_at

      t.timestamps
    end
  end
end
