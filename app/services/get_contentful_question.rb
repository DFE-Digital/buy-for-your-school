require "contentful"

class GetContentfulQuestion
  def call(entry_id:)
    contentful_client.entry(entry_id).raw
  end

  private

  def contentful_client
    @contentful_client ||= Contentful::Client.new(
      space: ENV["CONTENTFUL_SPACE"],
      access_token: ENV["CONTENTFUL_ACCESS_TOKEN"]
    )
  end
end
