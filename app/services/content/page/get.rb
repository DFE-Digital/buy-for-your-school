require "dry-initializer"
require "types"

# Retrieve Page entries from Contentful
#
class Content::Page::Get
  extend Dry::Initializer

  # @!attribute [r] page_entry_id
  # @return [String]
  option :page_entry_id, Types::String
  # @!attribute [r] client
  # @return [Content::Client]
  option :client, default: proc { Content::Client.new }

  # @return [Contentful::Entry]
  def call
    page = client.by_id(page_entry_id)

    send_rollbar_error(message: "A Contentful page entry was not found") if page.nil?

    page
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
