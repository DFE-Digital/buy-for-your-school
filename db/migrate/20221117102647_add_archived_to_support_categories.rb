class AddArchivedToSupportCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :support_categories, :archived, :boolean, default: false
  end
end
