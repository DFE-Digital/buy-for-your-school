class GuidanceLink
  include ActiveModel::Model

  attr_reader :id, :link_text, :url, :description

  def initialize(entry)
    @id = entry.id
    @link_text = entry.fields[:link_text]
    @url = entry.fields[:url]
    @description = entry.fields[:description]
  end
end
