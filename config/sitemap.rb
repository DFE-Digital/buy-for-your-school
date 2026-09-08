# frozen_string_literal: true

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://get-help-buying-for-schools.education.gov.uk"

# rubocop:disable all
SitemapGenerator::Sitemap.create(include_root: false) do
  def view_lastmod(template)
    full_path = Rails.root.join("app", "views", "#{template}.html.erb")
    Time.zone.at(`git log -1 --format="%ct" -- #{full_path}`.to_i).to_date
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
end
# rubocop:enable all
