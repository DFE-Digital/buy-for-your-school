class UpdatePrecisionInSupportCases < ActiveRecord::Migration[7.1]
  def up
    execute "DROP VIEW IF EXISTS support_tower_cases CASCADE;"
    change_column :support_contracts, :spend, :decimal, precision: 10, scale: 2
    change_table :support_cases, bulk: true do |t|
      t.change :savings_estimate, :decimal, precision: 10, scale: 2
      t.change :value, :decimal, precision: 10, scale: 2
      t.change :savings_actual, :decimal, precision: 10, scale: 2
    end
    create_view :support_tower_cases, version: 4
    create_view :support_case_data, version: 11
  end

  def down
    execute "DROP VIEW IF EXISTS support_tower_cases CASCADE;"
    change_column :support_contracts, :spend, :decimal, precision: 9, scale: 2
    change_table :support_cases, bulk: true do |t|
      t.change :savings_estimate, :decimal, precision: 9, scale: 2
      t.change :value, :decimal, precision: 9, scale: 2
      t.change :savings_actual, :decimal, precision: 9, scale: 2
    end
    create_view :support_tower_cases, version: 4
    create_view :support_case_data, version: 11
  end
end
