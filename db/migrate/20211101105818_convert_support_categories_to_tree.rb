class ConvertSupportCategoriesToTree < ActiveRecord::Migration[6.1]
  def change
    remove_column :support_cases, :sub_category_string, :string
    add_column :support_categories, :parent_id, :uuid

    ## Move unique constraint up into rails layer so that we can apply it only
    ## within the scope of its parent.
    reversible do |dir|
      dir.up do
        remove_index :support_categories, :title
        add_index :support_categories, :title
      end

      dir.down do
        remove_index :support_categories, :title
        add_index :support_categories, :title, unique: true
      end
    end
  end
end
