class ConvertSupportCategoriesToTree < ActiveRecord::Migration[6.1]
  def change
    remove_column :support_cases, :sub_category_string, :string
    add_column :support_categories, :parent_id, :uuid

    ## Convert unique constraint to compound index
    ## (A title can be duplicate but must be unqiue within its parent category)
    reversible do |dir|
      dir.up do
        remove_index :support_categories, :title
        add_index :support_categories, %i[title parent_id], unique: true
      end

      dir.down do
        remove_index :support_categories, :title
        add_index :support_categories, :title, unique: true
      end
    end
  end
end
