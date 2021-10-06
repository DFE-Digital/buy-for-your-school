class AddEmailToSupportAgents < ActiveRecord::Migration[6.1]
  def change
    add_column :support_agents, :email, :string, null: false, default: ""
    add_index :support_agents, :email
  end
end
