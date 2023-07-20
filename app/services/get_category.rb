# TODO: stop monkey-patching Contentful::Entry and start by moving this into the correct namespace
class Contentful::Entry
  attr_accessor :combined_specification_template
end

# Fetch and cache a Contentful category then concatenate and validate the Liquid template
#
class GetCategory
  include InsightsTrackable

  class InvalidLiquidSyntax < StandardError; end

  # @param category_entry_id [String] Contentful Entry ID
  # @param client [Content::Client]
  #
  def initialize(category_entry_id:, client: Content::Client.new)
    @category_entry_id = category_entry_id
    @client = client
  end

  # @return [Contentful::Entry]
  def call
    category = begin
      GetEntry.new(entry_id: @category_entry_id, client: @client).call
    rescue GetEntry::EntryNotFound
      track_error("GetCategory/ContentfulCategoryNotFound")
      raise
    end

    # INFO: Due to a 50k character limit within Contentful we check to see if
    # we need to combine this value from multiple fields set on a Contentful Category.
    category.combined_specification_template = combined_specification_templates(category:)

    begin
      validate_liquid(template: category.combined_specification_template)
    rescue Liquid::SyntaxError => e
      track_error("GetCategory/InvalidSpecification")
      raise InvalidLiquidSyntax.new(message: e.message)
    end

    category
  end

private

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

  def tracking_base_properties
    super.merge(
      contentful_space_id: @client.space,
      contentful_environment: @client.environment,
      contentful_url: @client.api_url,
      contentful_entry_id: @category_entry_id,
    )
  end
end
