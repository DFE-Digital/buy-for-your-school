class AddCategoryIdToJourney < ActiveRecord::Migration[6.1]
  def change
    add_column :journeys, :contentful_id, :string
  end
end
