# Interface wrapper for Contentful::Client
#
#
class Content::Client
  # Switch draft/published content and environment using env vars
  #
  # @param type [Symbol]
  #
  # @return [Contentful::Client]
  def initialize(type = :delivery)
    @client =
      Content::Connector.instance(
        ENV["CONTENTFUL_SPACE"],
        ENV["CONTENTFUL_DELIVERY_TOKEN"],
        ENV["CONTENTFUL_PREVIEW_TOKEN"],
      ).client(type)
  end

  # @return [String]
  def space
    @client.space.id
  end

  # @return [String]
  def environment
    @client.configuration[:environment]
  end

  # @return [String]
  def base_url
    @client.base_url
  end

  # @return [String]
  def api_url
    @client.configuration[:api_url]
  end

  # @return [Array<String>] 'English (United States)', '...'
  #
  # def locales
  #   @client.locales.map(&:name)
  # end

  # @return [Array<String>] category, question, section, statement, task
  #
  # def content_types
  #   @client.content_types.map(&:id).sort
  # end

  # @param entry_id [String]
  #
  # @return [Contentful::Entry]
  #
  def by_id(entry_id)
    @client.entry(entry_id)
  end

  # @param type [String, Symbol]
  #
  # @return [Contentful::Array]
  #
  def by_type(type)
    @client.entries(content_type: type.to_s)
  end

  # @param type [String, Symbol]
  # @param slug [String]
  #
  # @return [Contentful::Entry]
  #
  def by_slug(type, slug)
    @client.entries(content_type: type.to_s, "fields.slug" => slug).first
  end
end
