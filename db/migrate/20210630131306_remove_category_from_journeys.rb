class RemoveCategoryFromJourneys < ActiveRecord::Migration[6.1]
  def change
    remove_column :journeys, :category, :string
  end
end
