class RelatedContent
  include ActiveModel::Model

  attr_reader :id, :link_text, :url

  def initialize(entry)
    @id = entry.id
    @link_text = entry.fields[:link_text]
    @url = entry.fields[:url]
  end
end
