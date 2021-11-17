class AddContefulFieldsToPage < ActiveRecord::Migration[6.1]
  def change
    add_column :pages, :contentful_id, :string, null: false
    add_column :pages, :sidebar, :text

    add_index :pages, :contentful_id, unique: true
  end
end
