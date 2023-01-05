class AddDetectedCategoryIdToSupportCases < ActiveRecord::Migration[7.0]
  def change
    add_column :support_cases, :detected_category_id, :uuid
  end
end
