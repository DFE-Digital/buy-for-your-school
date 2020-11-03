require "contentful"

class GetContentfulQuestion
  def call
    contentful_client.entry("1UjQurSOi5MWkcRuGxdXZS").raw
  end

  private

  def contentful_client
    @contentful_client ||= Contentful::Client.new(
      space: ENV["CONTENTFUL_SPACE"],
      access_token: ENV["CONTENTFUL_ACCESS_TOKEN"]
    )
  end
end
