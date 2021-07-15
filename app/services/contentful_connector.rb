require "contentful"

# Wrapper initialising Contentful Client
#
class ContentfulConnector
  # Switch draft/published content and environment using env vars
  #
  # @return [Contentful::Client]
  def initialize
    @contentful_client = Contentful::Client.new(
      api_url: ENV["CONTENTFUL_URL"],
      space: ENV["CONTENTFUL_SPACE"],
      environment: ENV["CONTENTFUL_ENVIRONMENT"],
      access_token: ENV["CONTENTFUL_ACCESS_TOKEN"],
    )
  end

  # @return [Contentful::Entry]
  def get_entry_by_id(entry_id)
    @contentful_client.entry(entry_id)
  end

  # @return [Contentful::Array]
  def get_all_entries_by_type(type)
    @contentful_client.entries(content_type: type)
  end
end
