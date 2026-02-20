class Offer
  include ActiveModel::Model
  include HasRelatedContent

  attr_reader :id, :title, :description, :summary,
              :slug, :url, :call_to_action,
              :image, :featured_on_homepage, :expiry, :sort_order

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @description = entry.fields[:description]
    @summary = entry.fields[:summary]
    @slug = entry.fields[:slug]
    @url = entry.fields[:url]
    @call_to_action = entry.fields[:call_to_action]
    @image = entry.fields[:image]
    @featured_on_homepage = entry.fields[:featured_on_homepage]
    @expiry = entry.fields[:expiry]
    @sort_order = entry.fields[:sort_order]
    super
  end

  def self.find_by_slug!(slug)
    entry = ContentfulClient.entries(
      content_type: "offer",
      'fields.slug': slug,
      select: %w[
        sys.id
        fields.title
        fields.description
        fields.summary
        fields.slug
        fields.url
        fields.call_to_action
        fields.image
        fields.featured_on_homepage
        fields.related_content
        fields.expiry
        fields.sort_order
      ].join(","),
      include: 1,
    ).find { |offer| offer.fields[:slug] == slug }

    raise ContentfulRecordNotFoundError.new("Offer not found", slug:) unless entry

    new(entry)
  end

  def self.all
    params = {
      content_type: "offer",
      select: %w[
        sys.id
        fields.title
        fields.description
        fields.summary
        fields.slug
        fields.url
        fields.call_to_action
        fields.image
        fields.featured_on_homepage
        fields.related_content
        fields.expiry
        fields.sort_order
      ].join(","),
      order: "fields.sort_order",
    }
    ContentfulClient.entries(params).map { |entry| new(entry) }
  end

  def self.featured_offers
    params = {
      content_type: "offer",
      select: %w[
        sys.id
        fields.title
        fields.description
        fields.summary
        fields.slug
        fields.url
        fields.call_to_action
        fields.image
        fields.featured_on_homepage
        fields.expiry
        fields.sort_order
      ].join(","),
      "fields.featured_on_homepage": true,
      order: "fields.sort_order",
    }
    ContentfulClient.entries(params).map { |entry| new(entry) }
  end

  def ==(other)
    super || other.instance_of?(self.class) && other.id == id
  end
end
