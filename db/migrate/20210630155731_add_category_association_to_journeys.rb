class AddCategoryAssociationToJourneys < ActiveRecord::Migration[6.1]
  def change
    change_table :journeys do |t|
      t.belongs_to :category, type: :uuid
    end
  end
end
