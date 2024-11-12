class NormalizeSupportAgentEmailCase < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      UPDATE support_agents
      SET email = lower(email)
    SQL
  end

  def down
    raise IrreversibleMigration
  end
end
