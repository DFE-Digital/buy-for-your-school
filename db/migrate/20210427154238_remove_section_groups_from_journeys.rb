class RemoveSectionGroupsFromJourneys < ActiveRecord::Migration[6.1]
  def change
    remove_column :journeys, :section_groups, :jsonb
  end
end
