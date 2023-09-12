class CreateFrameworksFrameworks < ActiveRecord::Migration[7.0]
  def change
    create_table :frameworks_frameworks, id: :uuid do |t|
      t.integer :source, default: 0
      t.integer :status, default: 0

      t.uuid :support_category_id

      t.string :name
      t.string :short_name

      t.string :url
      t.string :reference
      t.string :description

      t.uuid :provider_id, null: false
      t.uuid :provider_contact_id

      t.date :provider_start_date
      t.date :provider_end_date
      t.date :dfe_start_date
      t.date :dfe_end_date

      t.string :sct_framework_owner
      t.string :sct_framework_provider_lead

      t.uuid :proc_ops_lead_id
      t.uuid :e_and_o_lead_id

      t.timestamps
    end
  end
end
