class UpdateSupportEstablishmentSearchesToVersion4 < ActiveRecord::Migration[7.1]
  def up
    replace_view :support_establishment_searches, version: 4, revert_to_version: 3
  end

  def down
    drop_view :ticket_searches
    drop_view :support_case_searches
    drop_view :support_establishment_searches

    create_view :support_establishment_searches, version: 3
    create_view :support_case_searches, version: 4
    create_view :ticket_searches, version: 1
  end
end
