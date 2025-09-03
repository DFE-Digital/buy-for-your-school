class AddArchivedToSupportAgents < ActiveRecord::Migration[7.2]
  def change
    add_column :support_agents, :archived, :boolean, default: false
  end
end
