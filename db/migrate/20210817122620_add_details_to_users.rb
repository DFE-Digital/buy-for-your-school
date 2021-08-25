class AddDetailsToUsers < ActiveRecord::Migration[6.1]
  def change
    change_table :users, bulk: true do |t|
      t.column :email, :string
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :full_name, :string

      # DSI: persist raw data from DSI API queries
      t.column :orgs, :jsonb
      t.column :roles, :jsonb

      t.index :email
      t.index :full_name
      t.index :first_name
      t.index :last_name
    end
  end
end
