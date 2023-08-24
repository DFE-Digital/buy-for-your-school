class CreateSupportCaseOrganisations < ActiveRecord::Migration[7.0]
  def change
    create_table :support_case_organisations, id: :uuid do |t|
      t.references :support_case, foreign_key: { to_table: :support_cases }, type: :uuid, null: false
      t.references :support_organisation, foreign_key: { to_table: :support_organisations }, type: :uuid, null: false
      t.timestamps
    end
  end
end
