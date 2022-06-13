class AddTriageAttributesToCases < ActiveRecord::Migration[6.1]
  def change
    change_table :support_cases, bulk: true do |t|
      t.column :procurement_amount, :decimal, precision: 9, scale: 2
      t.column :confidence_level, :string
      t.column :special_requirements, :string
    end
  end
end
