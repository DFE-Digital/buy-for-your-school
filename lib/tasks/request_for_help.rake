namespace :request_for_help do
  desc "Seed all data"
  task seed: :environment do
    RequestForHelp::SeedCategories.new.call
  end

  desc "Populate the categories table"
  task seed_categories: :environment do
    RequestForHelp::SeedCategories.new.call
  end
end
