require "contentful"

class GetContentfulEntry
  class EntryNotFound < StandardError; end

  attr_accessor :entry_id

  def initialize(entry_id:)
    self.entry_id = entry_id
  end

  def call
    response = contentful_client.entry(entry_id)

    if response.nil?
      send_rollbar_warning
      raise EntryNotFound
    end

    response
  end

  private

  def contentful_client
    @contentful_client ||= Contentful::Client.new(
      api_url: ENV["CONTENTFUL_URL"],
      space: ENV["CONTENTFUL_SPACE"],
      environment: ENV["CONTENTFUL_ENVIRONMENT"],
      access_token: ENV["CONTENTFUL_ACCESS_TOKEN"]
    )
  end

  def send_rollbar_warning
    Rollbar.warning(
      "The following Contentful entry identifier could not be found.",
      contentful_url: ENV["CONTENTFUL_URL"],
      contentful_space_id: ENV["CONTENTFUL_SPACE"],
      contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
      contentful_entry_id: entry_id
    )
  end
end
