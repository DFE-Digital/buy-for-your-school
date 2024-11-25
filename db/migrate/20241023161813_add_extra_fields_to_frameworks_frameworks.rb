class AddExtraFieldsToFrameworksFrameworks < ActiveRecord::Migration[7.1]
  change_table :frameworks_frameworks, bulk: true do |t|
    t.column :faf_slug_ref, :string
    t.column :faf_category, :string
    t.column :faf_archived_at, :date
    t.column :is_archived, :boolean, default: false
  end
end
