class PopularLink
  include ActiveModel::Model

  CONTENT_TYPE = "popularLink".freeze
  SORT_ORDER_FIELD = "fields.sortOrder".freeze
  SELECT_FIELDS = [
    "sys.id",
    "fields.title",
    "fields.url",
    SORT_ORDER_FIELD,
  ].join(",").freeze

  attr_reader :id, :title, :url, :sort_order

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @url = entry.fields[:url]
    @sort_order = entry.fields[:sort_order]
  end

  def self.all
    params = {
      content_type: CONTENT_TYPE,
      select: SELECT_FIELDS,
      order: SORT_ORDER_FIELD,
    }
    ContentfulClient.entries(params).map { |entry| new(entry) }
  end

  def ==(other)
    super || other.instance_of?(self.class) && other.id == id
  end
end
