class AddUniqueIndexToFrameworksFrameworks < ActiveRecord::Migration[7.1]
  def change
    add_index :frameworks_frameworks, [:name, :provider_id], unique: true
  end
end
