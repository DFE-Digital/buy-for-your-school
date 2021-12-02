class AddSavingsAttributesToSupportCase < ActiveRecord::Migration[6.1]
  def change
    change_table :support_cases, bulk: true do |t|
      t.integer :savings_status
      t.integer :savings_estimate_method
      t.integer :savings_actual_method
      t.decimal :savings_estimate, precision: 9, scale: 2
      t.decimal :savings_actual, precision: 9, scale: 2
    end
  end
end
