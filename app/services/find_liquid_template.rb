class FindLiquidTemplate
  class InvalidLiquidSyntax < StandardError; end

  attr_accessor :category, :environment

  def initialize(category:, environment: Rails.env)
    self.category = category
    self.environment = environment
  end

  def call
    validate_liquid
    file
  rescue Liquid::SyntaxError => error
    send_rollbar_error
    raise InvalidLiquidSyntax.new(message: error.message)
  end

  private def file
    @file ||= File.read("lib/specification_templates/#{category}.#{environment}.liquid")
  end

  private def validate_liquid
    Liquid::Template.parse(file, error_mode: :strict)
  end

  private def send_rollbar_error
    Rollbar.error(
      "A user couldn't start a journey because of an invalid Specification",
      contentful_url: ENV["CONTENTFUL_URL"],
      contentful_space_id: ENV["CONTENTFUL_SPACE"],
      contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
      category: category
    )
  end
end
