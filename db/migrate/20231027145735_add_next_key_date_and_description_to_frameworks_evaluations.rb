class AddNextKeyDateAndDescriptionToFrameworksEvaluations < ActiveRecord::Migration[7.0]
  def change
    change_table :frameworks_evaluations, bulk: true do |t|
      t.column :next_key_date, :date
      t.column :next_key_date_description, :string
    end
  end
end
