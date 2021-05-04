class CreateSection
  attr_accessor :journey, :contentful_section, :order

  def initialize(journey:, contentful_section:, order:)
    @journey = journey
    @contentful_section = contentful_section
    @order = order
  end

  def call
    section = Section.new(journey: journey, contentful_id: contentful_section.id, order: order, title: contentful_section.title)
    section.save!
    section
  end
end
