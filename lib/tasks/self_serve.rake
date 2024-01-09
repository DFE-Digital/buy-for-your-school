namespace :self_serve do
  desc "Backfill journey names"
  task backfill_journey_names: :environment do
    users_with_unnamed_journeys = User.joins(:journeys).where(journeys: { name: nil }).distinct

    # Get each user that has unnamed journeys
    users_with_unnamed_journeys.each do |user|
      # Sort unnamed journeys by creation date and group by category
      grouped_unnamed_journeys = user.journeys.includes(:category).where(name: nil).order(:created_at).group_by { |j| j.category.title }

      # Give names to all journeys that don't have them
      grouped_unnamed_journeys.each do |category, journeys|
        journeys.each_with_index do |journey, i|
          name = "#{category} specification #{sprintf('%02i', i + 1)}"
          journey.update!(name:)
        end
      end
    end
  end

  desc "Populate Contentful categories"
  task populate_categories: :environment do
    client = Content::Client.new

    client.by_type(:category).each do |entry|
      contentful_category = GetCategory.new(category_entry_id: entry.id).call
      CreateCategory.new(contentful_category:).call
    end
  end

  desc "Backfill contentful text fields"
  task backfill_contentful_text: :environment do
    ActivityLogItem.where(contentful_category: nil).find_each do |c|
      c.contentful_category = c.category&.title
      c.contentful_section = c.section&.title
      c.contentful_task = c.task&.title
      c.contentful_step = c.step&.title
      c.save!
    end
  end

  desc "Populate Contentful pages"
  task populate_pages: :environment do
    client = Content::Client.new

    client.by_type(:page).each do |entry|
      Content::Page::Build.new(contentful_page: entry).call
    end
  end
end
