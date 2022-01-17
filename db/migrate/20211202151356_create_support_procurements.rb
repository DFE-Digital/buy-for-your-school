class CreateSupportProcurements < ActiveRecord::Migration[6.1]
  def change
    create_table :support_procurements, id: :uuid do |t|
      t.integer :required_agreement_type
      t.integer :route_to_market
      t.integer :reason_for_route_to_market
      t.string :framework_name
      t.date :started_at
      t.date :ended_at
      t.integer :stage

      t.timestamps

      t.index :stage
    end
  end
end
