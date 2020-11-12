class CreatePlanTable < ActiveRecord::Migration[6.0]
  def change
    create_table :plans, id: :uuid do |t|
      t.string :category, null: false
      t.timestamps
    end
  end
end
