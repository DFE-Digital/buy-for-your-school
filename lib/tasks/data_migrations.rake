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
end
