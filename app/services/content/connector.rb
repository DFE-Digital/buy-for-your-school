require "contentful"

# Instantiate Contentful::Client for delivery and preview
#
class Content::Connector
  class UnexpectedClient < StandardError; end

  # @param space_id [String]
  # @param delivery_token [String]
  # @param preview_token [String]
  #
  # @return [Content::Connector]
  def self.instance(space_id, delivery_token, preview_token)
    if @instance.nil? ||
        @instance.space_id != space_id ||
        @instance.delivery_token != delivery_token ||
        @instance.preview_token != preview_token

      @instance = new(space_id, delivery_token, preview_token)
    end

    @instance
  end

  # @see spec/services/content/client_spec.rb
  #
  # @return [Nil]
  def self.reset!
    @instance = nil
  end

  # @param space_id [String]
  # @param access_token [String] Delivery or Preview API access token
  # @param preview [Boolean] whether the client uses the Preview API
  #
  # @return [::Contentful::Client]
  def self.create_client(space_id:, access_token:, preview: false)
    api_url = preview ? "preview.contentful.com" : "cdn.contentful.com"

    ::Contentful::Client.new(
      api_url:,
      space: space_id,
      access_token:,
      environment: ENV["CONTENTFUL_ENVIRONMENT"],
      raise_errors: true,
      application_name: "DfE: Buy For Your School",
      application_version: "1.0.0",
    )
  end

  # @param api [Symbol, String]
  #
  # @return [::Contentful::Client]
  def client(api)
    case api.to_sym
    when :preview then @preview_client
    when :delivery then @delivery_client
    else
      raise UnexpectedClient, "must be either 'preview' or 'delivery'"
    end
  end

  # @return [String]
  attr_reader :space_id
  # @return [String]
  attr_reader :delivery_token
  # @return [String]
  attr_reader :preview_token

private

  def initialize(space_id, delivery_token, preview_token)
    @space_id = space_id
    @delivery_token = delivery_token
    @preview_token = preview_token

    @delivery_client = self.class.create_client(
      space_id:,
      access_token: delivery_token,
      preview: false,
    )

    @preview_client = self.class.create_client(
      space_id:,
      access_token: preview_token,
      preview: true,
    )
  end
end
