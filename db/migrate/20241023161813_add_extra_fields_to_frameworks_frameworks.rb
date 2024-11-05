class AddExtraFieldsToFrameworksFrameworks < ActiveRecord::Migration[7.1]
  def change
    add_column :frameworks_frameworks, :faf_slug_ref, :string
    add_column :frameworks_frameworks, :faf_category, :string
    add_column :frameworks_frameworks, :faf_archived_at, :date
    add_column :frameworks_frameworks, :is_archived, :boolean, default: false
  end
end
