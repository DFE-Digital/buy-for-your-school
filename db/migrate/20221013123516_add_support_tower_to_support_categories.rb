class AddSupportTowerToSupportCategories < ActiveRecord::Migration[7.0]
  def change
    add_reference :support_categories, :support_tower, foreign_key: true, type: :uuid, index: true
  end
end
