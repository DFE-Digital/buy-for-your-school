namespace :data_migrations do
  desc "PWNN-965 New Category Structure"
  task pwnn_965_new_category_structure: :environment do
    # change category parents

    move_parent_categories = {
      "Books" => "Business Services",
      "Insurance" => "Business Services",
      "Leasing" => "Business Services",
      "Spend Analysis" => "Business Services",
      "Stationery supply & office supplies" => "Business Services",
      "Transport" => "Business Services",
      "Solar" => "Energy",
      "Boilers and plumbing services" => "FM",
      "Furniture" => "FM",
    }
    move_parent_categories.each do |sub_category_title, new_parent_category_title|
      Support::Category.change_sub_category_parent!(sub_category_title:, new_parent_category_title:)
    end

    # rename categories

    Support::Category.find_by(title: "Professional").update!(title: "Professional Services", slug: "professional-services")
    Support::Category.find_by(title: "Professional services Bloom").update!(title: "Specialist professional services")
    Support::Category.find_by(title: "Equipment").update!(title: "Catering Equipment")
    Support::Category.find_by(title: "Grounds Maintenance").update!(title: "Grounds & Winter Maintenance")
    Support::Category.find_by(title: "MUGAs (Multi Use Games Area)").update!(title: "MUGAs")
    Support::Category.find_by(title: "Security").update!(title: "Security & CCTV")
    Support::Category.find_by(title: "Statutory testing").update!(title: "Statutory testing & FM Compliance")
    Support::Category.find_by(title: "VLEs").update!(title: "Platforms (VLEs)")
    Support::Category.find_by(title: "Other").update!(title: "Other (General)")

    # pick up new categories & set archive status

    Rake::Task["case_management:seed_categories"].invoke
  end

  desc "Populate case attachments#attachable with existing email atts and energy bills"
  task populate_case_attachments_attachables: :environment do
    # Migrate email attachment ids to be attachable ids
    Support::CaseAttachment
      .where("support_email_attachment_id IS NOT null")
      .update_all("
        attachable_id = support_email_attachment_id,
        attachable_type = 'Support::EmailAttachment',
        custom_name = name")

    # Copy over energy bills to appear as case attachments
    EnergyBill.find_each do |energy_bill|
      Support::CaseAttachment
        .find_or_create_by!(
          attachable: energy_bill,
          case: energy_bill.support_case,
        )
        .update(
          custom_name: energy_bill.file_name,
          description: "User uploaded energy bill",
          created_at: energy_bill.created_at,
          updated_at: energy_bill.updated_at,
        )
    end
  end

  desc "Backfill email recipients"
  task backfill_email_recipients: :environment do
    messages = MicrosoftGraph.client.list_messages(SHARED_MAILBOX_USER_ID, query: [
      "$select=internetMessageId,toRecipients,ccRecipients,bccRecipients",
      "$orderby=lastModifiedDateTime desc",
    ])

    map_recipients = ->(recipients) { recipients.map(&:values).flatten if recipients.present? }

    messages.each do |message|
      email = Support::Email.find_by(outlook_internet_message_id: message["internetMessageId"])
      next if email.blank?

      email.update!(
        to_recipients: map_recipients.call(message["toRecipients"]),
        cc_recipients: map_recipients.call(message["ccRecipients"]),
        bcc_recipients: map_recipients.call(message["bccRecipients"]),
      )
    end
  end

  desc "Initialize Support::Agent roles from flags"
  task initialize_agent_roles: :environment do
    Support::Agent.find_each do |agent|
      agent.roles = []
      agent.roles << agent.internal ? "internal" : "procops"
      agent.roles << "procops_admin" if agent.user.admin?
      agent.roles << "analyst" if agent.user.analyst?
      agent.save!
    end
  end

  desc "Populate Support::Framework refs"
  task populate_framework_refs: :environment do
    uri = URI.parse(ENV["FAF_FRAMEWORK_ENDPOINT"])
    response =
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        request = Net::HTTP::Get.new(uri)
        http.request(request)
      end

    if response.code == "200"
      frameworks = JSON.parse(response.body)
      prepared_frameworks = frameworks.map do |framework|
        {
          name: framework["title"],
          supplier: framework["provider"]["initials"],
          ref: framework["ref"],
        }
      end

      Support::Framework.all.find_each do |framework|
        match = prepared_frameworks.select { |p| p[:name] == framework.name && p[:supplier] == framework.supplier }
        framework.update!(ref: match.first[:ref]) if match.present?
      end
    end
  end
end
