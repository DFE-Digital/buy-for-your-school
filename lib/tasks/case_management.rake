namespace :case_management do
  desc "Seed all data"
  task seed: :environment do
    Support::SeedCategories.new.call
    Support::SeedGroups.new.call
    Support::SeedSchools.new.call
  end

  desc "Populate the categories and sub_categories tables"
  task seed_categories: :environment do
    Support::SeedCategories.new.call
  end

  desc "Populate supported establishment group types"
  task seed_groups: :environment do
    Support::SeedGroups.new.call
  end

  desc "Populate the organisations"
  task seed_schools: :environment do
    Support::SeedSchools.new.call # live data from GIAS
    # Support::SeedSchools.new(data: "spec/fixtures/gias/example_schools_data.csv").call
  end

  desc "Backfill case procurement details"
  task backfill_procurement_details: :environment do
    Support::Case.where(procurement: nil).each do |c|
      c.procurement = Support::Procurement.create!
      c.new_contract = Support::NewContract.create!
      c.existing_contract = Support::ExistingContract.create!
      c.save!
    end
  end

  desc "Populate shared inbox emails"
  task seed_shared_inbox_emails: :environment do
    Support::IncomingEmails::SharedMailbox.synchronize(folder: :inbox)
    Support::IncomingEmails::SharedMailbox.synchronize(folder: :sent_items)
  end
end
