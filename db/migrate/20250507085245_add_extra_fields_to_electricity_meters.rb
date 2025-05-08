class AddExtraFieldsToElectricityMeters < ActiveRecord::Migration[7.2]
  change_table :energy_electricity_meters, bulk: true do |t|
    t.column :is_half_hourly, :boolean
    t.column :supply_capacity, :string
    t.column :data_aggregator, :string
    t.column :data_collector, :string
    t.column :meter_operator, :string
    t.column :electricity_usage, :string
  end
end
