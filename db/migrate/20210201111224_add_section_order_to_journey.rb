class AddSectionOrderToJourney < ActiveRecord::Migration[6.1]
  def change
    add_column :journeys, :section_ordering, :jsonb
  end
end
