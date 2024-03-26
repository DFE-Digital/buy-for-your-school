class UpdateSupportEstablishmentSearchesToVersion3 < ActiveRecord::Migration[7.1]
  def change
    replace_view :support_establishment_searches, version: 3, revert_to_version: 2
  end
end
