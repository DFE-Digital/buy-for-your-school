desc "populate pages table with .md files in /static"
task populate_pages: :environment do
  # clear existing entries so .find_by in PagesController
  # doesn't load outdated text
  Page.destroy_all

  # loop markdown files in static and load them into pages table
  Dir.glob("./static/*.md").each do |file_path|
    slug = file_path.split("/").last.gsub(".md", "")

    Page.create!(
      title: slug.humanize.capitalize,
      body: File.read(file_path),
      slug: file_path.split("/").last.gsub(".md", ""),
    )
  end
end
