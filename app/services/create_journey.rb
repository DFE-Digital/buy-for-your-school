class CreateJourney
  attr_accessor :category_name

  def initialize(category_name:)
    self.category_name = category_name
  end

  def call
    category = GetCategory.new(category_entry_id: ENV["CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID"]).call

    journey = Journey.create(
      category: category_name,
      liquid_template: category.specification_template
    )

    question_entries = GetEntriesInCategory.new(category: category).call
    question_entries.each do |entry|
      CreateJourneyStep.new(
        journey: journey, contentful_entry: entry
      ).call
    end
    journey
  end
end
