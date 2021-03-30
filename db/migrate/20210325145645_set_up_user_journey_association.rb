class SetUpUserJourneyAssociation < ActiveRecord::Migration[6.1]
  def change
    change_table :journeys do |t|
      t.belongs_to :user, type: :uuid
    end
  end
end
