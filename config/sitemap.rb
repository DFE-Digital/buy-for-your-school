# frozen_string_literal: true

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://get-help-buying-for-schools.education.gov.uk"

SitemapGenerator::Sitemap.create(include_root: false) do
  def view_lastmod(template)
    full_path = Rails.root.join("app", "views", "#{template}.html.erb")
    Time.at(`git log -1 --format="%ct" -- #{full_path}`.to_i).to_date
  end
  # Root
  add "/", lastmod: view_lastmod("categories/index")

  # Categories
  FABS::Category.all.each do |category|
    add "/categories/#{category.slug}", lastmod: category.updated_at
  end

  # Solutions
  Solution.all.as_json.each do |solution|
    category_slug = solution[:cat][:ref]
    add "/categories/#{category_slug}/#{solution[:ref]}", lastmod: solution[:updated_at]
  end

  # Pages
  ContentfulClient.entries(content_type: "page", include: 4).each do |page|
    add "/#{page.fields[:slug]}", lastmod: page.updated_at
  end
end
