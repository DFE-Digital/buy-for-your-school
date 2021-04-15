class CreateSection
  attr_accessor :journey, :contentful_section

  def initialize(journey:, contentful_section:)
    @journey = journey
    @contentful_section = contentful_section
  end

  def call
    section = Section.new(journey: journey, contentful_id: contentful_section.id, title: contentful_section.title)
    section.save!
    section
  end
end
