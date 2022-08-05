# Convert a {Contentful::Entry} into a {Section}
#
class CreateSection
  attr_accessor :journey, :contentful_section, :order

  # @param journey [Journey] persisted journey
  # @param contentful_section [Contentful::Entry] Contentful Client object
  # @param order [Integer] position within the category
  #
  def initialize(journey:, contentful_section:, order:)
    @journey = journey
    @contentful_section = contentful_section
    @order = order
  end

  # @return [Section]
  def call
    section = Section.new(
      journey:,
      contentful_id: contentful_section.id,
      title: contentful_section.title,
      order:,
    )
    section.save!
    section
  end
end
