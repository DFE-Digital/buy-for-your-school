class CreateJourney
  attr_accessor :category_name

  def initialize(category_name:)
    self.category_name = category_name
  end

  def call
    category = GetCategory.new(category_entry_id: ENV["CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID"]).call

    journey = Journey.new(
      category: category_name,
      liquid_template: category.specification_template
    )

    journey.section_ordering = GetSectionsInCategory.new(category: category).call
    journey.save

    question_entries = GetEntriesInCategory.new(category: category).call
    question_entries.each do |entry|
      CreateJourneyStep.new(
        journey: journey, contentful_entry: entry
      ).call
    end
    journey
  end
end
