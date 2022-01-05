class AddInternalToSupportAgents < ActiveRecord::Migration[6.1]
  def change
    add_column :support_agents, :internal, :boolean, null: false, default: false
  end
end
