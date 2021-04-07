class AddContentfulIdToSections < ActiveRecord::Migration[6.1]
  def change
    add_column :sections, :contentful_id, :string
  end
end
