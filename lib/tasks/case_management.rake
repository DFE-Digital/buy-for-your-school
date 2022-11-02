namespace :case_management do
  desc "Seed all data"
  task seed: :environment do
    Support::SeedCategories.new.call
    Support::SeedGroupTypes.new.call
    Support::SeedSchools.new.call
    Support::SeedEstablishmentGroupTypes.new.call
    Support::SeedEstablishmentGroups.new.call
    Support::SeedQueries.new.call
  end

  desc "Populate the categories and sub_categories tables"
  task seed_categories: :environment do
    Support::SeedCategories.new.call
  end

  desc "Populate the queries tables"
  task seed_queries: :environment do
    Support::SeedQueries.new.call
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

  desc "Move sub category to new parent"
  task :change_sub_category_parent, %i[sub_category_title new_parent_category_title] => :environment do |_task, args|
    sub_category = Support::Category.find_by(title: args.sub_category_title)
    new_parent_category = Support::Category.find_by(title: args.new_parent_category_title)

    sub_category.update!(parent: new_parent_category)
  end

  desc "Backfill email uniqueBody field"
  task backfill_email_unique_body: :environment do
    messages = MicrosoftGraph.client.list_messages(SHARED_MAILBOX_USER_ID, query: [
      "$select=internetMessageId,uniqueBody",
      "$orderby=lastModifiedDateTime desc",
    ])
    messages.each do |message|
      email = Support::Email.find_by(outlook_internet_message_id: message["internetMessageId"])

      if message["uniqueBody"].present? && email.present?
        email.update!(unique_body: message["uniqueBody"]["content"])
      end
    end
  end

  desc "Send the all cases survey email to case contacts"
  task :send_all_cases_survey, %i[case_refs_csv] => :environment do |_task, args|
    CSV.foreach(args.case_refs_csv, headers: true) do |row|
      Support::SendAllCasesSurveyJob.perform_later(row["case_ref"])
    end
  end
end
