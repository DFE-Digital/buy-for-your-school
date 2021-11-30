class CreateSupportHubTransitions < ActiveRecord::Migration[6.1]
  def change
    create_table :support_hub_transitions, id: :uuid do |t|
      t.references :case, type: :uuid
      t.string :hub_case_ref
      t.date :estimated_procurement_completion_date
      t.decimal :estimated_savings, precision: 8, scale: 2
      t.string :school_urn
      t.string :buying_category
      t.timestamps
      t.index :hub_case_ref
    end
  end
end
