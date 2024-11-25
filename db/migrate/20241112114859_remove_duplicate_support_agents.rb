class RemoveDuplicateSupportAgents < ActiveRecord::Migration[7.2]
  def up
    [
      %w[case_requests created_by_id],
      %w[frameworks_evaluations assignee_id],
      %w[frameworks_frameworks proc_ops_lead_id],
      %w[frameworks_frameworks e_and_o_lead_id],
      %w[support_cases agent_id],
      %w[support_cases created_by_id],
      %w[support_email_templates created_by_id],
      %w[support_email_templates updated_by_id],
      %w[support_interactions agent_id],
      %w[support_notifications assigned_to_id],
      %w[support_notifications assigned_by_id],
    ].each do |table, fkey|
      execute <<~SQL
        UPDATE #{table} t
        SET #{fkey} = (
          SELECT b.id
          FROM support_agents b
          WHERE lower(a.email) = lower(b.email)
          ORDER BY created_at
          LIMIT 1
        )
        FROM support_agents a
        WHERE t.#{fkey} IS NOT NULL
        AND a.id = t.#{fkey}
      SQL
    end

    execute <<~SQL
      DELETE FROM support_agents a
        USING support_agents b
      WHERE
        a.created_at > b.created_at
        AND lower(a.email) = lower(b.email)
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
