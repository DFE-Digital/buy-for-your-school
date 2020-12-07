class ChangeNameOfPlansToJourney < ActiveRecord::Migration[6.0]
  def self.up
    remove_foreign_key :questions, :plans

    rename_table :plans, :journeys
    rename_column :questions, :plan_id, :journey_id

    add_foreign_key :questions, :journeys, on_delete: :cascade
  end

  def self.down
    remove_foreign_key :questions, :journeys

    rename_table :journeys, :plans
    rename_column :questions, :journey_id, :plan_id

    add_foreign_key :questions, :plans, on_delete: :cascade
  end
end
