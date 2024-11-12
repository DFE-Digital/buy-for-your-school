class EnforceSupportAgentEmailUniqueness < ActiveRecord::Migration[7.2]
  def up
    remove_index :support_agents, :email
    add_index :support_agents, :email, unique: true
  end

  def down
    remove_index :support_agents, :email
    add_index :support_agents, :email
  end
end
