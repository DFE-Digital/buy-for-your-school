class CreateSection
  attr_accessor :journey, :contentful_section, :order

  def initialize(journey:, contentful_section:, order:)
    @journey = journey
    @contentful_section = contentful_section
    @order = order
  end

  def call
    section = Section.new(
      journey: journey,
      contentful_id: contentful_section.id,
      title: contentful_section.title,
      order: order
    )
    section.save!
    section
  end
end
