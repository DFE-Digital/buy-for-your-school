class CreateSupportEstablishmentSearches < ActiveRecord::Migration[6.1]
  def change
    # This should not be needed but the order of migrations has corrupted on github
    execute "DROP VIEW IF EXISTS support_case_searches;"
    execute "DROP VIEW IF EXISTS support_establishment_searches;"
    create_view :support_establishment_searches
  end
end
