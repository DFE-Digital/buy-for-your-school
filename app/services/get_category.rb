class Contentful::Entry
  attr_accessor :combined_specification_template
end

# Fetch and cache a Contentful category then concatenate and validate the Liquid template
#
class GetCategory
  class InvalidLiquidSyntax < StandardError; end

  # @return [String]
  attr_accessor :category_entry_id

  # @param category_entry_id [String] Contentful Entry ID
  def initialize(category_entry_id:)
    self.category_entry_id = category_entry_id
  end

  # @return [Contentful::Entry]
  def call
    category = begin
      GetEntry.new(entry_id: category_entry_id).call
    rescue GetEntry::EntryNotFound
      send_rollbar_error(message: "A Contentful category entry was not found", entry_id: category_entry_id)
      raise
    end

    # INFO: Due to a 50k character limit within Contentful we check to see if
    # we need to combine this value from multiple fields set on a Contentful Category.
    category.combined_specification_template = combined_specification_templates(category: category)

    begin
      validate_liquid(template: category.combined_specification_template)
    rescue Liquid::SyntaxError => e
      send_rollbar_error(message: "A user couldn't start a journey because of an invalid Specification", entry_id: category_entry_id)
      raise InvalidLiquidSyntax.new(message: e.message)
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
      contentful_entry_id: entry_id,
    )
  end

  def validate_liquid(template:)
    Liquid::Template.parse(template, error_mode: :strict)
  end

  def combined_specification_templates(category:)
    specification_template_array = []

    # Allow a new `specification_template_part_x` field to be added in Contentful
    # without requiring an additional code change.
    all_specification_fields = (category.public_methods - Object.methods)
      .grep(/^specification_template(_part[0-9]+)*(?<!=)$/)
      .sort

    all_specification_fields.each do |specification_field|
      if category.respond_to?(specification_field)
        specification_template_array << category.send(specification_field)
      end
    end

    specification_template_array.compact.join("\n")
  end
end
