namespace :case_management do
  desc "Populate the categories and sub_categories tables"
  task seed_categories: :environment do
    Support::SeedCategories.new.call
  end
end
