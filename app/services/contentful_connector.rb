require "contentful"

class ContentfulConnector
  def initialize
    @contentful_client = Contentful::Client.new(
      api_url: ENV["CONTENTFUL_URL"],
      space: ENV["CONTENTFUL_SPACE"],
      environment: ENV["CONTENTFUL_ENVIRONMENT"],
      access_token: ENV["CONTENTFUL_ACCESS_TOKEN"],
    )
  end

  def get_entry_by_id(entry_id)
    @contentful_client.entry(entry_id)
  end

  def get_all_entries
    @contentful_client.entries
  end

  def get_all_entries_by_type(type)
    @contentful_client.entries(content_type: type)
  end
end
