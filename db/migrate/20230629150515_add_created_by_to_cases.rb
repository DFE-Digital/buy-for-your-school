class AddCreatedByToCases < ActiveRecord::Migration[7.0]
  def change
    add_column :support_cases, :created_by_id, :uuid
  end
end
