class CreateEnergyGasMeters < ActiveRecord::Migration[7.2]
  def change
    create_table :energy_gas_meters, id: :uuid do |t|
      t.references :energy_onboarding_case_organisation, foreign_key: true, type: :uuid
      t.string :mprn, null: false

      t.timestamps
    end
  end
end
