class AddGasUsageToEnergyGasMeter < ActiveRecord::Migration[7.2]
  def change
    add_column :energy_gas_meters, :gas_usage, :string
  end
end
