desc "populate pages table with .md files in /static"
task populate_pages: :environment do
  Dir.glob("./static/*.md").each do |file_path|
    slug = file_path.split("/").last.gsub(".md", "")

    Page.create!(
      title: slug.humanize.capitalize,
      body: File.read(file_path),
      slug: file_path.split("/").last.gsub(".md", ""),
    )
  end
end
