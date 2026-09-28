# frozen_string_literal: true

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://get-help-buying-for-schools.education.gov.uk"

# Static pages: maps the URL slug to its view template, where they differ.
# N.B. Ensure to update action.yml (build-docker-image) when adding new static pages
STATIC_PAGES = {
  "" => "categories/index",
  "energy/start" => "energy/onboarding/start",
  "energy/before-you-start" => "energy/onboarding/before_you_start",
  "energy/guidance" => "energy/onboarding/guidance",
  "procurement-support" => "framework_requests/framework_requests/index",
}.freeze

# rubocop:disable all
SitemapGenerator::Sitemap.create(include_root: false) do
  # Categories
  FABS::Category.all.each do |category|
    add "/categories/#{category.slug}", lastmod: category.updated_at
  end

  # Solutions
  Solution.all.each do |solution|
    category_slug = solution.primary_category.slug
    add "/categories/#{category_slug}/#{solution.slug}", lastmod: solution.updated_at
  end

  # Pages
  FABS::Page.all.each do |page|
    add "/#{page.slug}", lastmod: page.updated_at
  end

  # Static pages
  path = Rails.root.join("config", "view_lastmod.yml")
  templates_with_timestamps = File.exist?(path) ? YAML.safe_load_file(path) : {}

  STATIC_PAGES.each do |slug, template|
    lastmod_date = if templates_with_timestamps.key?(template)
      Time.zone.at(templates_with_timestamps.fetch(template).to_i).to_date
    else
      Time.zone.today
    end
    add "/#{slug}", lastmod: lastmod_date
  end
end
# rubocop:enable all
