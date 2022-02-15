class CreateSupportEstablishmentSearches < ActiveRecord::Migration[6.1]
  def change
    create_view :support_establishment_searches
  end
end
