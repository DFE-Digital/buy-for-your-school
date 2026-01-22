class ContentfulClient
  include Singleton

  def self.configure(**kwargs)
    instance.configure(**defaults.merge(kwargs))
  end

  def self.entries(*args, **kwargs)
    return [] if instance.missing_credentials?

    instance.client.entries(*args, **kwargs)
  rescue Contentful::BadRequest => e
    Rails.logger.error "Contentful query failed: #{e.message}"
    []
  end

  def configure(space:, access_token:, environment:)
    @space = space
    @access_token = access_token
    @environment = environment
    @client = nil
  end

  def missing_credentials?
    @space.blank? || @access_token.blank?
  end

  def client
    return nil if missing_credentials?

    @client ||= Contentful::Client.new(
      space: @space,
      access_token: @access_token,
      environment: @environment
    )
  end

  def self.defaults
    {
      space: ENV.fetch("CONTENTFUL_SPACE_ID", "FAKE_SPACE_ID"),
      access_token: ENV.fetch("CONTENTFUL_ACCESS_TOKEN", "FAKE_API_KEY"),
      environment: ENV.fetch("CONTENTFUL_ENVIRONMENT", "master"),
    }
  end

  private_class_method :defaults
end
