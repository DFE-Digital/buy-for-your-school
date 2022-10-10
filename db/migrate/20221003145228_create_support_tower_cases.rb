class CreateSupportTowerCases < ActiveRecord::Migration[7.0]
  def change
    create_view :support_tower_cases
  end
end
