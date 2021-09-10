class AddDefaultSupportCategoryTimestamps < ActiveRecord::Migration[6.1]
  def change
    change_table :support_categories, bulk: true do |t|
      t.change_default :created_at, from: nil, to: -> { "CURRENT_TIMESTAMP" }
      t.change_default :updated_at, from: nil, to: -> { "CURRENT_TIMESTAMP" }
    end
  end
end
