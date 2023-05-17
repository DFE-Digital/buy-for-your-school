class AddRolesToSupportAgents < ActiveRecord::Migration[7.0]
  def change
    add_column :support_agents, :roles, :string, array: true, default: []
  end
end
