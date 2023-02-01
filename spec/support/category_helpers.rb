module CategoryHelpers
  def define_categories(nested_categories)
    nested_categories.each do |parent_category, sub_categories|
      parent = create(:support_category, title: parent_category)
      sub_categories.each do |sub_category|
        create(:support_category, title: sub_category, parent:)
      end
    end
  end

  def define_basic_categories
    define_categories(
      "ICT" => %w[Peripherals Laptops Websites],
      "Or" => ["Not yet known", "No applicable category", "Other (General)"],
      "Energy" => %w[Electricity Gas Water],
    )
  end

  def gas_category
    Support::Category.find_by(title: "Gas")
  end

  def define_basic_queries
    ["Legal", "PPNs", "Playbook", "E&O Queries", "Other"].each do |query|
      create(:support_query, title: query)
    end
  end
end
