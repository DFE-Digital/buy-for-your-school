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
end
