class CreateJourney
  attr_accessor :category_name

  def initialize(category_name:)
    self.category_name = category_name
  end

  def call
    category = GetCategory.new(category_entry_id: ENV["CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID"]).call
    sections = GetSectionsFromCategory.new(category: category).call
    journey = Journey.new(
      category: category_name,
      liquid_template: category.specification_template
    )

    journey.section_groups = sections.each_with_object({}) { |section, result|
      result[section.title] = section.steps.map(&:id)
    }
    journey.save

    sections.each do |section|
      question_entries = GetStepsFromSection.new(section: section).call
      question_entries.each do |entry|
        CreateJourneyStep.new(
          journey: journey, contentful_entry: entry
        ).call
      end
    end

    journey
  end
end
