class AddOrganisationIdToCaseAdditionalContacts < ActiveRecord::Migration[7.1]
  def change
    add_column :support_case_additional_contacts, :organisation_id, :uuid
  end
end
