class AddDefaultSupportCategoryTimestamps < ActiveRecord::Migration[6.1]
  def change
    change_table :support_categories, bulk: true do |t|
      t.timestamps default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end
