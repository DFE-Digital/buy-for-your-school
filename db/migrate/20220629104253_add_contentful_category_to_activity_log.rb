class AddContentfulCategoryToActivityLog < ActiveRecord::Migration[6.1]
  def change
    change_table :activity_log, bulk: true do |t|
      t.column :contentful_category, :string
      t.column :contentful_section, :string
      t.column :contentful_task, :string
      t.column :contentful_step, :string
    end
  end
end
