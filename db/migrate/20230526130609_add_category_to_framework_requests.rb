class AddCategoryToFrameworkRequests < ActiveRecord::Migration[7.0]
  def change
    change_table :framework_requests, bulk: true do |t|
      t.references :category, foreign_key: { to_table: :request_for_help_categories }, type: :uuid
      t.column :category_other, :text
    end
  end
end
