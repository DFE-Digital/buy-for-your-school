class GetCategory
  class InvalidLiquidSyntax < StandardError; end

  attr_accessor :category_entry_id
  def initialize(category_entry_id:)
    self.category_entry_id = category_entry_id
  end

  def call
    category = begin
      GetEntry.new(entry_id: category_entry_id).call
    rescue GetEntry::EntryNotFound
      send_rollbar_error(message: "A Contentful category entry was not found", entry_id: category_entry_id)
      raise
    end

    begin
      validate_liquid(template: category.specification_template)
    rescue Liquid::SyntaxError => error
      send_rollbar_error(message: "A user couldn't start a journey because of an invalid Specification", entry_id: category_entry_id)
      raise InvalidLiquidSyntax.new(message: error.message)
    end

    category
  end

  private

  def send_rollbar_error(message:, entry_id:)
    Rollbar.error(
      message,
      contentful_url: ENV["CONTENTFUL_URL"],
      contentful_space_id: ENV["CONTENTFUL_SPACE"],
      contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
      contentful_entry_id: entry_id
    )
  end

  def validate_liquid(template:)
    Liquid::Template.parse(template, error_mode: :strict)
  end
end
