class AddMissingNullConstraintsToCategories < ActiveRecord::Migration[6.1]
  def change
    change_column_null :categories, :description, false
    change_column_null :categories, :slug, false
  end
end
