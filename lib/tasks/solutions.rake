require "csv"
require "yaml"

namespace :solutions do
  DESC = "Update config/solutions.yml with category and subcategory slugs from the recategorisation spreadsheet".freeze

  desc DESC
  task update_category_mapping: :environment do
    spreadsheet_path = Rails.root.join("DO NOT EDIT - Categories_BuyingOptions(Recategorising frameworks).csv")
    solutions_path = Rails.root.join("config/solutions.yml")
    categories_path = Rails.root.join("config/categories.yml")

    spreadsheet_rows = CSV.read(spreadsheet_path, headers: true, encoding: "bom|utf-8")
    solutions_file = YAML.load_file(solutions_path)
    solutions = Array(solutions_file["solutions"])
    category_lookup, subcategory_lookup = build_title_lookups(categories_path)

    solutions_by_normalised_title = solutions.index_by { |solution| normalise_title(solution["title"]) }
    solutions_by_slug = solutions.index_by { |solution| solution["slug"] }

    updated = 0
    unmatched_rows = []
    unresolved_categories = []
    unresolved_subcategories = []
    invalid_buying_option_rows = []

    spreadsheet_rows.each_with_index do |row, index|
      row = row.to_h.transform_values { |value| value.is_a?(String) ? value.strip : value }
      row_number = index + 2
      title = row["Framework name or content name"].to_s
      slug = row["Framework slug"].to_s
      break if title.blank? && row.to_h.values.compact.map(&:to_s).all?(&:blank?)

      buying_option = lookup_buying_option(row["Type of buying option"], invalid_buying_option_rows, row_number)

      solution = if slug.present?
                   solutions_by_slug[slug]
                 else
                   solutions_by_slug[title.parameterize] || solutions_by_normalised_title[normalise_title(title)]
                 end

      if solution.nil?
        unmatched_rows << { row: row_number, title:, slug: }
        next
      end

      primary_category = lookup_slug(row["To-be primary category"], category_lookup, unresolved_categories, row_number)
      secondary_category = lookup_slug(row["To-be 2nd category (if applicable)"], category_lookup, unresolved_categories, row_number)
      categories = [primary_category, secondary_category].compact.uniq

      subcategory_slugs = (
        parse_values(row["Primary sub-categories"]).flat_map { |value| lookup_subcategory_slugs(value, subcategory_lookup, unresolved_subcategories, row_number) } +
          parse_values(row["Secondary sub-categories (if applicable)"]).flat_map { |value| lookup_subcategory_slugs(value, subcategory_lookup, unresolved_subcategories, row_number) }
      ).compact.uniq

      solution["primary_category"] = primary_category if primary_category.present?
      solution["categories"] = categories if categories.any?
      solution["subcategories"] = subcategory_slugs if subcategory_slugs.any?
      solution["ways_to_buy"] = buying_option if buying_option.present?
      updated += 1
    end

    File.write(solutions_path, solutions_file.to_yaml)

    puts "Updated #{updated} solutions in #{solutions_path}"
    puts "Unmatched solution rows: #{unmatched_rows.size}"
    unmatched_rows.each do |row|
      identifier = row[:slug].present? ? "#{row[:title]} (slug: #{row[:slug]})" : row[:title]
      puts "  - line #{row[:row]}: #{identifier}"
    end

    if unresolved_categories.any?
      puts "Unresolved category titles:"
      unresolved_categories.uniq.each { |row| puts "  - line #{row[:row]}: #{row[:value]}" }
    end

    if unresolved_subcategories.any?
      puts "Unresolved subcategory titles:"
      unresolved_subcategories.uniq.each { |row| puts "  - line #{row[:row]}: #{row[:value]}" }
    end

    puts "Unresolved ways to buy: #{invalid_buying_option_rows.count}"
    invalid_buying_option_rows.each { |row| puts "  - line #{row[:row]}: #{row[:value]}" }

    unmapped_buying_options = solutions.select { |solution| solution["ways_to_buy"].blank? }
    puts "Solutions with no mapped ways_to_buy: #{unmapped_buying_options.count}"
    unmapped_buying_options.each do |solution|
      puts "  - #{solution['title']} (#{solution['slug']})"
    end

    solutions_with_no_mapped_categories = solutions.select do |solution|
      solution["primary_category"].blank? || Array(solution["categories"]).blank?
    end

    puts "Solutions with no mapped categories: #{solutions_with_no_mapped_categories.count}"
    solutions_with_no_mapped_categories.each do |solution|
      puts "  - #{solution['title']} (#{solution['slug']})"
    end

    solutions_with_no_mapped_subcategories = solutions.select do |solution|
      Array(solution["subcategories"]).blank?
    end

    puts "Solutions with no mapped subcategories: #{solutions_with_no_mapped_subcategories.count}"
    solutions_with_no_mapped_subcategories.each do |solution|
      puts "  - #{solution['title']} (#{solution['slug']})"
    end
  end
end

def build_title_lookups(categories_path)
  categories = YAML.load_file(categories_path).fetch("categories", [])

  category_lookup = {}
  subcategory_lookup = {}

  categories.each do |category|
    category_lookup[normalise_title(category["category"])] = category["slug"]

    Array(category["subcategories"]).each do |subcategory|
      subcategory_lookup[normalise_title(subcategory["name"])] = subcategory["slug"]
    end
  end

  category_lookup.merge!(category_aliases)
  subcategory_lookup.merge!(subcategory_aliases)

  [category_lookup, subcategory_lookup]
end

def category_aliases
  {
    normalise_title("Catering ") => "catering",
  }
end

def subcategory_aliases
  {
    normalise_title("Hardware") => "laptops-printers-ict-hardware",
    normalise_title("IT software and systems") => "ict-software-systems",
    normalise_title("N/A til there are more transport options") => [],
    normalise_title("Renewables and energy saving products") => "renewables-energysaving-products",
    normalise_title("Sports equipment, SEND") => ["sports-equipment", "send-products"],
    normalise_title("Catering services") => "catering-services-staff",
    normalise_title("[B&M]Health, safety and security") => "health-safety-security",
  }.compact
end

def parse_values(value)
  value.to_s.split(";").map(&:strip).reject(&:blank?)
end

def lookup_slug(value, lookup, unresolved, row_number)
  normalised = normalise_title(value)
  return nil if normalised.blank?

  slug = lookup[normalised]
  unresolved << { row: row_number, value: } if slug.nil?
  slug
end

def lookup_subcategory_slugs(value, lookup, unresolved, row_number)
  normalised = normalise_title(value)
  return [] if normalised.blank?

  slug = lookup[normalised]
  if slug.nil?
    unresolved << { row: row_number, value: }
    []
  else
    Array(slug)
  end
end

def lookup_buying_option(value, unresolved, row_number)
  raw_value = value.to_s.strip
  return nil if raw_value.blank?

  buying_options = {
    "Catalogue" => 'catalogue',
    "DfE deal" => 'dfe_deal',
    "DPS" => 'dps',
    "Framework" => 'framework'
  }

  buying_options[raw_value]
end

def normalise_title(value)
  value.to_s
    .strip
    .gsub(/^\[[^\]]+\]\s*/, "")
    .gsub(/\bfor schools?\b/i, "")
    .gsub(/dynamic purchasing system \(dps\)/i, "")
    .gsub(/\b(dps|catalogue|catalogues)\b/i, "")
    .gsub(/&/, "and")
    .gsub(/[^a-z0-9]+/i, " ")
    .squish
    .downcase
end
