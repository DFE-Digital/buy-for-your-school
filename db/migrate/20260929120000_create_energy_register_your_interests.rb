class CreateEnergyRegisterYourInterests < ActiveRecord::Migration[8.1]
  def change
    create_table :energy_register_your_interests, id: :uuid do |t|
      t.string :name
      t.string :email
      t.string :phone_number
      t.string :mat_uid
      t.string :mat_name
      t.string :ukprn
      t.boolean :switch_gas
      t.date :gas_contract_end_date
      t.boolean :switch_electricity
      t.date :electricity_contract_end_date
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
