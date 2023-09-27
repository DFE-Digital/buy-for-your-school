class ReSeedRfhCategories < ActiveRecord::Migration[7.0]
  def up
    Rake::Task["request_for_help:seed_categories"].invoke
  end

  def down; end
end
