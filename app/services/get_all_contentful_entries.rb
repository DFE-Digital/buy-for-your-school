require "contentful"

class GetAllContentfulEntries
  class NoEntriesFound < StandardError; end

  def initialize(contentful_connector: ContentfulConnector.new)
    @contentful_connector = contentful_connector
  end

  def call
    response = @contentful_connector.get_all_entries

    if response.nil?
      send_rollbar_error
      raise NoEntriesFound
    end

    response
  end

  private

  def send_rollbar_error
    Rollbar.warning(
      "Could not retrieve all entries from the following contentful environment.",
      contentful_url: ENV["CONTENTFUL_URL"],
      contentful_space_id: ENV["CONTENTFUL_SPACE"],
      contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"]
    )
  end
end
