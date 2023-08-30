class UpdateSupportTowerCasesToVersion4 < ActiveRecord::Migration[7.0]
  def change
    update_view :support_tower_cases, version: 4, revert_to_version: 3
  end
end
