require "contentful"

class GetContentfulQuestion
  class EntryNotFound < StandardError
    attr_accessor :message
    def initialize(message)
      @message = message
    end
  end

  def call(entry_id:)
    response = contentful_client.entry(entry_id)
    if response.nil?
      error_message = "The following Contentful entry identifier could not be found."
      Rollbar.warning(
        error_message,
        contentful_url: ENV["CONTENTFUL_URL"],
        contentful_space_id: ENV["CONTENTFUL_SPACE"],
        contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
        contentful_entry_id: entry_id
      )
      raise EntryNotFound.new(error_message)
    end

    response.raw
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
end
