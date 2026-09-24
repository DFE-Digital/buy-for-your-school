# frozen_string_literal: true

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://get-help-buying-for-schools.education.gov.uk"

# rubocop:disable all
SitemapGenerator::Sitemap.create(include_root: false) do
  def view_lastmod(template)
    full_path = Rails.root.join("app", "views", "#{template}.html.erb")
    File.mtime(full_path).to_date
  end
  # Root
  add "/", lastmod: view_lastmod("categories/index")

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

  # Static pages: maps the URL slug to its view template, where they differ
  def static_page_view
    {
      "energy/start" => "energy/onboarding/start",
      "energy/before-you-start" => "energy/onboarding/before_you_start",
      "energy/guidance" => "energy/onboarding/guidance",
      "procurement-support" => "framework_requests/framework_requests/index"
    }
  end

  static_page_view.each do |path, template|
    add "/#{path}", lastmod: view_lastmod(template)
  end
end
# rubocop:enable all
