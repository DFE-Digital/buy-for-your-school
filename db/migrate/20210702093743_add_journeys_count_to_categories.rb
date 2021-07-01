class AddJourneysCountToCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :categories, :journeys_count, :integer
  end
end
