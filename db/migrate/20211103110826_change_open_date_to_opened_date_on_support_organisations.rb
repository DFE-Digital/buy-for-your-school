class ChangeOpenDateToOpenedDateOnSupportOrganisations < ActiveRecord::Migration[6.1]
  def change
    rename_column :support_organisations, :open_date, :opened_date
  end
end
