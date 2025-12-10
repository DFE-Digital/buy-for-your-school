class AddContentfulIdToFrameworksFrameworks < ActiveRecord::Migration[7.1]
  def change
    add_column :frameworks_frameworks, :contentful_id, :string
    add_index :frameworks_frameworks, :contentful_id, unique: true
  end
end
