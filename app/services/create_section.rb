# CreateSection service is responsible for constructing a {Section} for the given journey.
class CreateSection
  attr_accessor :journey, :contentful_section, :order

  def initialize(journey:, contentful_section:, order:)
    @journey = journey
    @contentful_section = contentful_section
    @order = order
  end

  # Creates and persists a new Section.
  #
  # @return [Section]
  def call
    section = Section.new(
      journey: journey,
      contentful_id: contentful_section.id,
      title: contentful_section.title,
      order: order,
    )
    section.save!
    section
  end
end
