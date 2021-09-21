class AddAuthToSupportAgents < ActiveRecord::Migration[6.1]
  def change
    add_column :support_agents, :dsi_uid, :string, null: false, default: ""
    add_index :support_agents, :dsi_uid
  end
end
