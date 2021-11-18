require "dry-initializer"
require "types"

# Retrieves Page entries from Contentful
#
class Content::Page::Get
  extend Dry::Initializer

  # @!attribute [r] page_entry_id
  # @return [String]
  option :page_entry_id, Types::String
  # @!attribute [r] client
  # @return [Content::Client]
  option :client, default: proc { Content::Client.new }

  # @raise [GetEntry::EntryNotFound] if page entry is not found
  # @see GetEntry
  # @return [Contentful::Entry]
  def call
    GetEntry.new(entry_id: page_entry_id, client: client).call
  rescue GetEntry::EntryNotFound
    send_rollbar_error(message: "A Contentful page entry was not found")
    raise
  end

private

  def send_rollbar_error(message:)
    Rollbar.error(
      message,
      contentful_space_id: client.space,
      contentful_environment: client.environment,
      contentful_url: client.api_url,
      contentful_entry_id: page_entry_id,
    )
  end
end
