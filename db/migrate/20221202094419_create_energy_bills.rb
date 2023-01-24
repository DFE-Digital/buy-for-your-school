class CreateEnergyBills < ActiveRecord::Migration[7.0]
  def change
    create_table :energy_bills, id: :uuid do |t|
      t.integer :submission_status, default: 0
      t.string :filename
      t.integer :filesize
      t.references :support_cases, type: :uuid
      t.references :framework_requests, type: :uuid

      t.timestamps
    end
  end
end
