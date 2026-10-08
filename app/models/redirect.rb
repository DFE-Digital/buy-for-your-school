class Redirect
  include ActiveModel::Model

  CONTENT_TYPE = "redirect".freeze
  SELECT_FIELDS = [
    "sys.id",
    "fields.title",
    "fields.source_path",
    "fields.destination_path",
    "fields.redirect_type",
  ].join(",").freeze

  attr_reader :id, :title, :source_path, :destination_path, :redirect_type

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @source_path = entry.fields[:source_path]
    @destination_path = entry.fields[:destination_path]
    @redirect_type = entry.fields[:redirect_type]
    super()
  end

  def self.all
    ContentfulClient.entries(
      content_type: CONTENT_TYPE,
      select: SELECT_FIELDS,
      order: "fields.title",
    ).map { |entry| new(entry) }
  end

  def permanent?
    redirect_type == "permanent"
  end

  def temporary?
    redirect_type == "temporary"
  end

  def ==(other)
    super || other.instance_of?(self.class) && other.id == id
  end
end
