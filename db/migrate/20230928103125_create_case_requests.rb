class CreateCaseRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :case_requests, id: :uuid do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_number
      t.string :extension_number
      t.text :request_text
      t.boolean :submitted, default: false
      t.references :created_by, foreign_key: { to_table: :support_agents }, type: :uuid
      t.uuid :organisation_id
      t.string :organisation_type
      t.references :category, foreign_key: { to_table: :support_categories }, type: :uuid
      t.references :query, foreign_key: { to_table: :support_queries }, type: :uuid
      t.column :other_category, :string
      t.column :other_query, :string
      t.decimal :procurement_amount, precision: 9, scale: 2
      t.string :school_urns, array: true, default: []
      t.integer :discovery_method
      t.string :discovery_method_other_text
      t.integer :source
      t.integer :creation_source
      t.references :support_case, foreign_key: { to_table: :support_cases }, type: :uuid
      t.timestamps
    end
  end
end
