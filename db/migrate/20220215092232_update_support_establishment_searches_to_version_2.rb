class UpdateSupportEstablishmentSearchesToVersion2 < ActiveRecord::Migration[6.1]
  def change
    replace_view :support_establishment_searches, version: 2, revert_to_version: 1
  end
end
