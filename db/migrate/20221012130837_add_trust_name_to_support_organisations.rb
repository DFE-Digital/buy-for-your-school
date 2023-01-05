class AddTrustNameToSupportOrganisations < ActiveRecord::Migration[7.0]
  def change
    add_column :support_organisations, :trust_name, :string
  end
end
