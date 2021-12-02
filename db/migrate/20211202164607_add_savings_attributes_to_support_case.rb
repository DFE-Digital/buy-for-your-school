class AddSavingsAttributesToSupportCase < ActiveRecord::Migration[6.1]
  def change
    change_table :support_cases, bulk: true do |t|
      t.integer :savings_status, :integer
      t.integer :savings_estimate_method, :integer
      t.integer :savings_actual_method, :integer
      t.decimal :savings_estimate, :decimal, precision: 9, scale: 2
      t.decimal :savings_actual, :decimal, precision: 9, scale: 2
    end
  end
end
