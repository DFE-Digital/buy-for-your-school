require "contentful"

# Function using Contentful client wrapper
#
# @deprecated Using {WarmEntryCacheJob} instead?
#
class GetAllContentfulEntries
  class NoEntriesFound < StandardError; end

  def initialize(contentful_connector: ContentfulConnector.new)
    @contentful_connector = contentful_connector
  end

  # @raise [GetAllContentfulEntries::NoEntriesFound]
  #
  # @return [Contentful::Array]
  def call
    response = @contentful_connector.get_all_entries

    if response.nil?
      send_rollbar_error
      raise NoEntriesFound
    end

    response
  end

  # @param [String] type Contentful entry type (e.g. task, category)
  #
  # @see ContentfulConnector#get_all_entries_by_type
  #
  # @return [Contentful::Array]
  def by_type(type)
    @contentful_connector.get_all_entries_by_type(type)
  end

private

  def send_rollbar_error
    Rollbar.warning(
      "Could not retrieve all entries from the following contentful environment.",
      contentful_url: ENV["CONTENTFUL_URL"],
      contentful_space_id: ENV["CONTENTFUL_SPACE"],
      contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
    )
  end
end
