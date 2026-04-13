require "json"
require "contentful/management"

# rubocop:disable Rails/SaveBang
namespace :contentful do
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

def unique_categories(json_data)
  json_data.map { |item| item["cat"] }.uniq
end

def create_categories(environment, json_data)
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
# rubocop:enable Rails/SaveBang
