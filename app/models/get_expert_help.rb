class GetExpertHelp
  include ActiveModel::Model

  CONTENT_TYPE = "get_expert_help".freeze
  SELECT_FIELDS = [
    "sys.id",
    "fields.title",
    "fields.description",
  ].join(",").freeze

  attr_reader :id, :title, :description

  def initialize(entry)
    @id = entry&.id
    @title = entry&.fields&.[](:title)
    @description = entry&.fields&.[](:description)
  end

  def self.content
    entry = ContentfulClient.entries(
      content_type: CONTENT_TYPE,
      select: SELECT_FIELDS,
    ).first

    new(entry)
  end
end
