require "contentful"

# Instantiate Contentful::Client for delivery and preview
#
#
class Content::Connector
  # Gets or creates a Contentful Service Wrapper
  #
  # @param space_id [String]
  # @param delivery_token [String]
  # @param preview_token [String]
  # @param host [String]
  #
  # @return [Content::Connector]
  def self.instance(space_id, delivery_token, preview_token, host = nil)
    @instance ||= nil

    # We create new client instances only if credentials changed or client wasn't instantiated before
    if @instance.nil? ||
        @instance.space_id != space_id ||
        @instance.delivery_token != delivery_token ||
        @instance.preview_token != preview_token ||
        @instance.host != host

      @instance = new(space_id, delivery_token, preview_token, host)
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
  # @param preview [Boolean] wether or not the client uses the Preview API
  # @param host [String]
  #
  # @return [::Contentful::Client]
  def self.create_client(space_id:, access_token:, host:, preview: false)
    host ||= "contentful"
    api_url = preview ? "preview.#{host}.com" : "cdn.#{host}.com"

    options = {
      api_url: api_url,
      space: space_id,
      access_token: access_token,
      environment: ENV["CONTENTFUL_ENVIRONMENT"],
      raise_errors: true,
      application_name: "DfE: Buy For Your School",
      application_version: "1.0.0",
    }

    ::Contentful::Client.new(options)
  end

  # Returns the corresponding client (Delivery or Preview)
  #
  # @param api_id [Symbol, String]
  #
  # @return [::Contentful::Client]
  def client(api_id)
    case api_id.to_sym
    when :preview then @preview_client
    when :delivery then @delivery_client
    else
      raise StandardError, "Unknown endpoint, must be either :preview or :delivery"
    end
  end

  # @return [String]
  attr_reader :space_id
  # @return [String]
  attr_reader :delivery_token
  # @return [String]
  attr_reader :preview_token
  # @return [String]
  attr_reader :host

private

  def initialize(space_id, delivery_token, preview_token, host)
    @space_id = space_id
    @delivery_token = delivery_token
    @preview_token = preview_token
    @host = host

    @delivery_client = self.class.create_client(
      space_id: space_id,
      access_token: delivery_token,
      preview: false,
      host: host,
    )

    @preview_client = self.class.create_client(
      space_id: space_id,
      access_token: preview_token,
      preview: true,
      host: host,
    )
  end
end
