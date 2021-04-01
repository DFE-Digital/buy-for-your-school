class CreateUserTable < ActiveRecord::Migration[6.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :dfe_sign_in_uid, null: false
      t.timestamps
    end
  end
end
