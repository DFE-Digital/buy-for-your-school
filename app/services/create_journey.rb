class CreateJourney
  attr_accessor :category

  def initialize(category:)
    self.category = category
  end

  def call
    journey = Journey.create(
      category: category,
      next_entry_id: ENV["CONTENTFUL_PLANNING_START_ENTRY_ID"],
      liquid_template: liquid_template
    )

    question_entries = GetEntriesInCategory.new(category_entry_id: ENV["CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID"]).call
    question_entries.each do |entry|
      CreateJourneyStep.new(
        journey: journey, contentful_entry: entry
      ).call
    end
    journey
  end

  private def liquid_template
    FindLiquidTemplate.new(category: category).call
  end
end
