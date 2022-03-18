class AddNameToJourney < ActiveRecord::Migration[6.1]
  def change
    add_column :journeys, :name, :string
  end
end
