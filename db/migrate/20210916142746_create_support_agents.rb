class CreateSupportAgents < ActiveRecord::Migration[6.1]
  def change
    create_table :support_agents, id: :uuid do |t|
      t.string "dfe_support_sign_in_uid", null: false
      t.string "email"
      t.string "first_name"
      t.string "last_name"
      t.string "full_name"
      t.jsonb "orgs"
      t.jsonb "roles"

      t.timestamps
    end
  end
end
