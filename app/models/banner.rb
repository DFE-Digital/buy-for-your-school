class Banner
  include ActiveModel::Model

  attr_reader :id, :title, :description, :call_to_action, :url, :image, :slug

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @description = entry.fields[:description]
    @call_to_action = entry.fields[:call_to_action]
    @url = entry.fields[:url]
    @slug = entry.fields[:slug]
    @image = entry.fields[:image]
  end

  def self.find_by_slug(slug)
    entry = ContentfulClient.entries(
      content_type: "banner",
      'fields.slug': slug,
      limit: 1
    ).first
    entry ? new(entry) : nil
  rescue ContentfulRecordNotFoundError => e
    Rollbar.error(e, slug: slug)
    nil
  end
end
