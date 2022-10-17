class AddMoreTrustFieldsToSupportOrganisations < ActiveRecord::Migration[7.0]
  def change
    add_column :support_organisations, :trust_code, :string
    add_column :support_organisations, :gor_name, :string
  end
end
