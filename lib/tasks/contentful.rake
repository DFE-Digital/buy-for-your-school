require "json"
require "contentful/management"
require "yaml"

# rubocop:disable Rails/SaveBang
namespace :contentful do
  desc "Download published solutions to config/solutions.yml"
  task export_solutions: :environment do
    puts "Exporting published solutions to config/solutions.yml..."

    environment = contentful_environment
    solutions = environment.entries.all(content_type: "solution", limit: 1000)
      .select(&:published?)
      .map { |entry| { "title" => entry.title.strip, "slug" => entry.fields[:slug] } }
      .sort_by { |solution| solution["slug"] }

    file = Rails.root.join("config/solutions.yml")
    File.write(file, { "solutions" => solutions }.to_yaml)

    puts "Wrote #{solutions.count} published solutions to #{file}"
  end

  desc "Update existing Contentful solutions from config/solutions.yml"
  task update_solutions: :environment do
    puts "Updating Contentful solutions from config/solutions.yml..."

    environment = contentful_environment
    solutions_data = YAML.load_file(Rails.root.join("config/solutions.yml")).fetch("solutions", [])

    solutions_by_slug = published_entries_by_slug(environment, "solution")
    categories_by_slug = published_entries_by_slug(environment, "category")
    subcategories_by_slug = published_entries_by_slug(environment, "subcategory")
    ways_to_buy_by_slug = published_entries_by_slug(environment, "ways_to_buy")

    updated = 0
    unmatched_solutions = []
    unmatched_categories = []
    unmatched_subcategories = []
    unmatched_ways_to_buy = []
    skipped_solutions = []

    solutions_data.each do |solution_data|
      solution_slug = solution_data["slug"].to_s
      solution_entry = solutions_by_slug[solution_slug]

      if solution_entry.nil?
        unmatched_solutions << solution_slug
        next
      end

      primary_category_slug = solution_data["primary_category"].presence
      category_slugs = Array(solution_data["categories"]).presence || []
      subcategory_slugs = Array(solution_data["subcategories"]).presence || []
      ways_to_buy_slug = solution_data["ways_to_buy"].presence

      primary_category_entry = primary_category_slug && categories_by_slug[primary_category_slug]
      category_entries = category_slugs.filter_map { |slug| categories_by_slug[slug] }
      subcategory_entries = subcategory_slugs.filter_map { |slug| subcategories_by_slug[slug] }
      ways_to_buy_entry = ways_to_buy_slug && ways_to_buy_by_slug[ways_to_buy_slug]

      if primary_category_slug.present? && primary_category_entry.nil?
        unmatched_categories << { solution: solution_slug, slug: primary_category_slug }
      end

      (category_slugs - category_entries.map { |entry| entry.fields[:slug] }).each do |slug|
        unmatched_categories << { solution: solution_slug, slug: }
      end

      (subcategory_slugs - subcategory_entries.map { |entry| entry.fields[:slug] }).each do |slug|
        unmatched_subcategories << { solution: solution_slug, slug: }
      end

      if ways_to_buy_slug.present? && ways_to_buy_entry.nil?
        unmatched_ways_to_buy << { solution: solution_slug, slug: ways_to_buy_slug }
      end

      if primary_category_slug.present? && primary_category_entry.nil? ||
          category_entries.size != category_slugs.size ||
          subcategory_entries.size != subcategory_slugs.size ||
          ways_to_buy_slug.present? && ways_to_buy_entry.nil?
        skipped_solutions << solution_slug
        next
      end

      update_attributes = {}
      update_attributes[:primary_category] = primary_category_entry if primary_category_slug.present?
      update_attributes[:categories] = category_entries if solution_data.key?("categories")
      update_attributes[:subcategories] = subcategory_entries if solution_data.key?("subcategories")

      if ways_to_buy_slug.present?
        ways_to_buy_field = solution_buying_option_field(solution_entry)
        update_attributes[ways_to_buy_field] = ways_to_buy_entry if ways_to_buy_field
      end

      next if update_attributes.empty?

      puts "Updating #{solution_entry.title} (#{solution_slug})"
      solution_entry.update(**update_attributes)
      solution_entry.publish
      updated += 1
    end

    puts "Updated #{updated} solutions"

    if unmatched_solutions.any?
      puts "Solutions not found: #{unmatched_solutions.uniq.count}"
      unmatched_solutions.uniq.sort.each { |slug| puts "  - #{slug}" }
    end

    if unmatched_categories.any?
      puts "Categories not found: #{unmatched_categories.uniq.count}"
      unmatched_categories.uniq.sort_by { |item| [item[:slug], item[:solution]] }.each do |item|
        puts "  - #{item[:slug]} (solution: #{item[:solution]})"
      end
    end

    if unmatched_subcategories.any?
      puts "Subcategories not found: #{unmatched_subcategories.uniq.count}"
      unmatched_subcategories.uniq.sort_by { |item| [item[:slug], item[:solution]] }.each do |item|
        puts "  - #{item[:slug]} (solution: #{item[:solution]})"
      end
    end

    if unmatched_ways_to_buy.any?
      puts "Ways to buy not found: #{unmatched_ways_to_buy.uniq.count}"
      unmatched_ways_to_buy.uniq.sort_by { |item| [item[:slug], item[:solution]] }.each do |item|
        puts "  - #{item[:slug]} (solution: #{item[:solution]})"
      end
    end

    if skipped_solutions.any?
      puts "Solutions skipped due to unresolved references: #{skipped_solutions.uniq.count}"
      skipped_solutions.uniq.sort.each { |slug| puts "  - #{slug}" }
    end
  end

  desc "Create or update subcategories from config/categories.yml in Contentful"
  task create_subcategories: :environment do
    data = categories_config
    environment = contentful_environment
    subcategory_type = environment.content_types.find("subcategory")

    each_subcategory(data) do |sub_category|
      slug = sub_category["slug"]
      entry = find_entry_by_slug(environment, "subcategory", slug)

      if entry
        puts "Updating subcategory #{sub_category['name']} (#{slug})"
        entry.update(
          title: sub_category["name"],
          slug:,
        )
      else
        puts "Creating subcategory #{sub_category['name']} (#{slug})"
        entry = subcategory_type.entries.create(
          id: slug,
          title: sub_category["name"],
          slug:,
        )
      end

      entry.publish
    end

    puts "Subcategory creation complete."
  end

  desc "Create or update categories from config/categories.yml in Contentful"
  task create_categories: :environment do
    data = categories_config
    environment = contentful_environment
    category_type = environment.content_types.find("category")

    data.fetch("categories", []).each do |category|
      slug = category["slug"]
      subcategory_entries = Array(category["subcategories"]).map do |sub_category|
        entry = find_entry_by_slug(environment, "subcategory", sub_category["slug"])
        raise "Missing subcategory #{sub_category['name']} (#{sub_category['slug']}). Run contentful:create_subcategories first." unless entry

        entry
      end
      entry = find_entry_by_slug(environment, "category", slug)

      if entry
        puts "Updating category #{category['category']} (#{slug})"
        entry.update(
          title: category["category"],
          description: category["description"],
          slug:,
          subcategories: subcategory_entries,
        )
      else
        puts "Creating category #{category['category']} (#{slug})"
        entry = category_type.entries.create(
          id: slug,
          title: category["category"],
          description: category["description"],
          slug:,
          subcategories: subcategory_entries,
        )
      end

      entry.publish
    end

    puts "Category creation complete."
  end

  desc "Fetches all solutions and checks if their URLs are working"
  task check_solution_urls: :environment do
    puts "Fetching all solutions and checking URLs..."

    solutions = Solution.all

    if solutions.empty?
      puts "No solutions found."
    else
      solutions.each do |solution|
        if solution.url.blank?
          puts "Solution '#{solution.title}' (ID: #{solution.id}, Slug: #{solution.slug}) has no URL."
          next
        end

        begin
          uri = URI.parse(solution.url)
          response = Net::HTTP.get_response(uri)
          status_code = response.code.to_i

          unless (200..299).cover?(status_code) || (300..399).cover?(status_code)
            puts "  ERROR: Status #{status_code} for '#{solution.title}' (ID: #{solution.id}, Slug: #{solution.slug}, URL: #{solution.url})"
          end
        rescue SocketError => e
          puts "  ERROR: Could not connect to '#{solution.title}' (ID: #{solution.id}, Slug: #{solution.slug}, URL: #{solution.url}) (SocketError: #{e.message})"
        rescue URI::InvalidURIError => e
          puts "  ERROR: Invalid URL for '#{solution.title}' (ID: #{solution.id}, Slug: #{solution.slug}, URL: #{solution.url}) (URI::InvalidURIError: #{e.message})"
        rescue StandardError => e
          puts "  ERROR: An unexpected error occurred for '#{solution.title}' (ID: #{solution.id}, Slug: #{solution.slug}, URL: #{solution.url}) (#{e.class}: #{e.message})"
        end
      end
    end

    puts "URL check complete."
  end

  desc "Unpublish expired solutions"
  task unpublish_expired_solutions: :environment do
    client = Contentful::Management::Client.new(ENV["CONTENTFUL_CMA_TOKEN"])
    space = client.spaces.find(ENV["CONTENTFUL_SPACE_ID"])
    environment = space.environments.find(ENV.fetch("CONTENTFUL_ENVIRONMENT", "master"))

    expired_entries = environment.entries.all(
      content_type: "solution",
      "fields.expiry[lt]": Time.zone.today.iso8601,
    )

    if expired_entries.empty?
      puts "No expired solutions found."
      Rollbar.info("No expired solutions found", rake_task: "contentful:unpublish_expired_solutions")
      next
    end

    published_expired = expired_entries.select(&:published?)

    if published_expired.empty?
      puts "Found #{expired_entries.count} expired solutions, but all are already unpublished."
      Rollbar.info("All expired solutions already unpublished",
                   rake_task: "contentful:unpublish_expired_solutions",
                   total_expired: expired_entries.count)
      next
    end

    puts "Found #{published_expired.count} published expired solutions to unpublish (#{expired_entries.count - published_expired.count} already unpublished)"

    unpublished_count = 0
    published_expired.each do |entry|
      entry.unpublish
      unpublished_count += 1
      puts "Unpublished: #{entry.title} (slug: #{entry.fields[:slug]}, expired: #{entry.fields[:expiry]})"
    rescue StandardError => e
      puts "ERROR: Failed to unpublish #{entry.title} (ID: #{entry.id}): #{e.message}"
      Rollbar.error(e, rake_task: "contentful:unpublish_expired_solutions", entry_id: entry.id, entry_title: entry.title, expiry: entry.fields[:expiry])
    end

    puts "Unpublishing complete. #{unpublished_count} of #{published_expired.count} solutions unpublished."
    Rollbar.info("Unpublished #{unpublished_count} of #{published_expired.count} expired solutions", rake_task: "contentful:unpublish_expired_solutions", count: unpublished_count, total: published_expired.count)
  rescue StandardError => e
    puts "ERROR: Contentful rake task  failed - Unpublish expired solutions: #{e.message}"
    Rollbar.error("Contentful rake task  failed - Unpublish expired solutions: #{e.message}", rake_task: "contentful:unpublish_expired_solutions")
    raise
  end

  desc "Update solutions with a primary category, \
    Run a dry run: rake contentful:update_solution_with_primary_category['dry_run'] \
    publish_all with out confirming: rake contentful:update_solution_with_primary_category['publish_all']"
  task :update_solution_with_primary_category, [:action] => :environment do |_t, args|
    publish_all = false
    dry_run = false

    if args[:action]
      publish_all = true if args[:action] == "publish_all"
      dry_run = true if args[:action] == "dry_run"
    end

    client = Contentful::Management::Client.new(ENV["CONTENTFUL_CMA_TOKEN"])
    space = client.spaces.find(ENV["CONTENTFUL_SPACE_ID"])
    environment = space.environments.find("master")

    # Get all solution without a primary category
    entries = environment.entries.all(content_type: "solution", "fields.primary_category" => nil)

    all_categories = FABS::Category.all.map { |category| [category.title, category.id] }.to_h

    categories_by_id = FABS::Category.all.map { |category| [category.id, category.title] }.to_h

    primary_categories = {
      "Energy cost recovery services" => "Energy",
      "Education decarbonisation" => "Energy",
      "Building in use - support services" => "Facilities management and estates",
      "Estates and facilities professional services" => "Primary is Facilities management and estates",
      "Specialist professional services" => "Consultancy services",
      "Debt resolution services" => "Consultancy",
      "LED lighting" => "Energy",
      "Audiovisual solutions" => "IT",
    }

    entries.each do |entry|
      categories = entry.categories
      puts "Solution: #{entry.title}"
      cat_name = ""
      if categories.count == 1
        id = categories.first["sys"]["id"]
        cat_name = categories_by_id[id]

        if cat_name.nil?
          skip_entry("Skipping because is missing a category")
          next
        end

        if dry_run == false
          entry.update(primary_category: categories.first)
        else
          puts "DRY RUN updating #{entry.title} with primary_category: #{cat_name}"
        end
      else
        cat_name = primary_categories[entry.title.strip]

        if cat_name.nil?
          skip_entry("Skipping because is missing a category")
          next
        end

        id = all_categories[cat_name]

        if id.nil?
          skip_entry("Skipping because is missing a category id")
          next
        end

        data = { "sys" => { "type" => "Link", "linkType" => "Entry", "id" => id } }
        if dry_run == false
          entry.update(primary_category: data)
        else
          puts "DRY RUN updating #{entry.title} with primary_category: #{cat_name}"
        end
      end

      if dry_run == true
        puts "DRY RUN: #{entry.title} has not been publish"
      elsif publish_all == true && dry_run == false
        entry.publish
        puts "#{entry.title} has been publish"
      else
        puts "Do you want to publish solution #{entry.title} with primary category #{cat_name}?"
        puts "Please type 'Yes' to publish or No to skip"
        input = $stdin.gets.chomp

        if input.downcase == "yes"
          entry.publish
          puts "#{entry.title} has been published"
        else
          puts "#{entry.title} has not been published"
        end
      end
      puts "------------------"
    end
  end
end

def categories_config
  YAML.load_file(Rails.root.join("config/categories.yml"))
end

def contentful_environment
  client = Contentful::Management::Client.new(ENV["CONTENTFUL_CMA_TOKEN"])
  space = client.spaces.find(ENV["CONTENTFUL_SPACE_ID"])
  space.environments.find(ENV.fetch("CONTENTFUL_ENVIRONMENT", "master"))
end

def published_entries_by_slug(environment, content_type)
  environment.entries.all(content_type:, limit: 1000)
    .select(&:published?)
    .each_with_object({}) do |entry, entries_by_slug|
      slug = entry.fields[:slug]
      entries_by_slug[slug] = entry if slug.present?
    end
end

def solution_buying_option_field(solution_entry)
  fields = solution_entry.fields
  return :ways_to_buy if fields.key?(:ways_to_buy)
  return :buying_option_type if fields.key?(:buying_option_type)

  :ways_to_buy
end

def each_subcategory(json_data)
  json_data.fetch("categories", []).each do |category|
    Array(category["subcategories"]).each { |sub_category| yield sub_category }
  end
end

def unique_categories(json_data)
  json_data.map { |item| item["cat"] }.uniq
end

def build_categories(environment, json_data)
  categories = {}
  unique_categories(json_data).each { |item| categories[item["ref"]] = create_category(environment, item) }
  categories
end

def create_solution(environment, item, category)
  start_line
  puts "-- Starting solution #{item['title']} --"
  solution_type = environment.content_types.find("solution")
  entries = environment.entries.all(content_type: "solution", "fields.slug" => item["ref"])
  entry = entries.first

  if entry
    puts "Updating existing solution"
    entry.update(
      title: item["title"],
      description: item["descr"],
      summary: item["body"],
      provider_name: item["provider"]["title"],
      provider_initials: item["provider"]["initials"],
      url: item["url"],
      expiry: item["expiry"],
      categories: (Array(entry.categories) + [category]).uniq,
      _metadata: {
        tags: [{ sys: { type: "Link", linkType: "Tag", id: "faf" } }],
      },
    )
  else
    puts "Creating solutions: #{item['title']} with slug #{item['ref']} "
    entry = solution_type.entries.create(
      title: item["title"],
      description: item["descr"],
      summary: item["body"],
      slug: item["ref"],
      provider_name: item["provider"]["title"],
      provider_initials: item["provider"]["initials"],
      url: item["url"],
      expiry: item["expiry"],
      categories: (Array(entry.categories) + [category]).uniq,
      _metadata: {
        tags: [{ sys: { type: "Link", linkType: "Tag", id: "faf" } }],
      },
    )
  end
  entry.publish
  entry
end

def create_category(environment, item)
  puts "category #{item['title']}"
  entries = environment.entries.all(content_type: "category", "fields.slug" => item["ref"])
  entry = entries.first

  if entry
    puts "Updating existing category"
    entry.update(title: item["title"],
                 _metadata: {
                   tags: [{ sys: { type: "Link", linkType: "Tag", id: "faf" } }],
                 })
  else
    puts "Creating category: #{item['title']} with slug #{item['ref']} "
    category_type = environment.content_types.find("category")
    entry = category_type.entries.create(
      title: item["title"],
      slug: item["ref"],
      description: "x",
      summary: "x",
      _metadata: {
        tags: [{ sys: { type: "Link", linkType: "Tag", id: "faf" } }],
      },
    )
  end
  entry.publish
  entry
end

def skip_entry(msg)
  puts msg
  puts "------------------"
end

def find_entry_by_slug(environment, content_type, slug)
  environment.entries.all(content_type:, "fields.slug" => slug).first
end
# rubocop:enable Rails/SaveBang
