namespace :case_management do
  desc "Seed all data"
  task seed: :environment do
    Support::SeedCategories.new.call
    Support::SeedGroupTypes.new.call
    Support::SeedSchools.new.call
    Support::SeedEstablishmentGroupTypes.new.call
    Support::SeedEstablishmentGroups.new.call
  end

  desc "Populate the categories and sub_categories tables"
  task seed_categories: :environment do
    Support::SeedCategories.new.call
  end

  desc "Populate supported group types for establishments"
  task seed_group_types: :environment do
    Support::SeedGroupTypes.new.call
  end

  desc "Populate the organisations"
  task seed_schools: :environment do
    Support::SeedSchools.new.call # live data from GIAS
    # Support::SeedSchools.new(data: "spec/fixtures/gias/example_schools_data.csv").call
  end

  desc "Populate supported establishment group types"
  task seed_establishment_group_types: :environment do
    Support::SeedEstablishmentGroupTypes.new.call
  end

  desc "Populate establishment groups"
  task seed_establishment_groups: :environment do
    Support::SeedEstablishmentGroups.new.call
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

  desc "Backfill case category"
  task backfill_case_category: :environment do
    category = Support::Category.find_by(title: "Not yet known")
    Support::Case.where(category_id: nil).update_all(category_id: category.id)
  end

  desc "Populate shared inbox emails"
  task seed_shared_inbox_emails: :environment do
    include Support::Messages::Outlook

    SynchroniseMailFolder.call(MailFolder.new(messages_after: Time.zone.parse("01/10/2021 00:00:00"), folder: :inbox))
    SynchroniseMailFolder.call(MailFolder.new(messages_after: Time.zone.parse("01/10/2021 00:00:00"), folder: :sent_items))
  end

  desc "Populate frameworks"
  task :seed_frameworks, [:file_path] => :environment do |_t, args|
    file_path = Rails.root.join(args[:file_path])
    Support::SeedFrameworks.new(data: file_path).call
  end

  desc "Re-sync ids of moved messages"
  task resync_moved_messages: :environment do
    incoming_email_went_live = Time.zone.parse("01/01/2022 00:00:00")
    resync_email_ids = Support::Messages::Outlook::ResyncEmailIds.new(messages_updated_after: incoming_email_went_live)
    resync_email_ids.call
  end
end
