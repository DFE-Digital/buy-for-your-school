class CreateJourney
  attr_accessor :category

  def initialize(category:)
    self.category = category
  end

  def call
    journey = Journey.create(
      category: category,
      liquid_template: liquid_template
    )

    category = GetCategory.new(category_entry_id: ENV["CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID"]).call
    question_entries = GetEntriesInCategory.new(category: category).call
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
