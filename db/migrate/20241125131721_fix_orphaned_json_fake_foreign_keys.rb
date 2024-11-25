class FixOrphanedJsonFakeForeignKeys < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      UPDATE support_interactions
      SET additional_data = additional_data || '{"assigned_to_agent_id": "9b93fe33-b9f7-417e-a0f8-51cac736b727"}'
      WHERE additional_data->'assigned_to_agent_id' @> '"f709fe43-10f9-4dcc-972a-7262bf30911b"'
    SQL
    execute <<~SQL
      UPDATE support_interactions
      SET additional_data = additional_data || '{"assigned_to_agent_id": "afb92ef7-e01a-4a63-8797-e52e8dbf428b"}'
      WHERE additional_data->'assigned_to_agent_id' @> '"dcda84b8-6329-4c87-90a4-884c0c55113d"'
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
