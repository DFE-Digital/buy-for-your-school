class DropSupportTowersView < ActiveRecord::Migration[7.0]
  def change
    drop_view :support_towers, revert_to_version: 1
  end
end
