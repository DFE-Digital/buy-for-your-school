class ReseedCategories < ActiveRecord::Migration[7.2]
  def up
    Rake::Task["case_management:seed_categories"].invoke
    Rake::Task["request_for_help:seed_categories"].invoke
  end

  def down; end
end
