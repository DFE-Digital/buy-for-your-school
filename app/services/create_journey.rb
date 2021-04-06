class CreateJourney
  attr_accessor :category_name, :user

  def initialize(category_name:, user:)
    self.category_name = category_name
    self.user = user
  end

  def call
    category = GetCategory.new(category_entry_id: ENV["CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID"]).call
    contentful_sections = GetSectionsFromCategory.new(category: category).call
    journey = Journey.new(
      category: category_name,
      user: user,
      started: true,
      last_worked_on: Time.zone.now,
      liquid_template: category.specification_template
    )

    journey.section_groups = build_section_groupings(sections: contentful_sections)
    journey.save!

    contentful_sections.each do |contentful_section|
      CreateSection.new(journey: journey, contentful_section: contentful_section).call

      question_entries = GetStepsFromSection.new(section: contentful_section).call
      question_entries.each do |entry|
        CreateJourneyStep.new(
          journey: journey, contentful_entry: entry
        ).call
      end

      tasks = GetTasksFromSection.new(section: contentful_section).call
      tasks.each do |task|
        CreateTask.new(section: contentful_section, contentful_task: task)
      end
    end

    contentful_sections.each do |section|
      tasks = GetTasksFromSection.new(section: section).call
      tasks.each do |task|
        CreateTask.new(section: section, contentful_task: task)
      end
    end

    journey
  end

  private def build_section_groupings(sections:)
    sections.each_with_object([]).with_index { |(section, result), index|
      result[index] = {
        order: index,
        title: section.title,
        steps: section.steps.each_with_object([]).with_index { |(step, result), index|
          result << {contentful_id: step.id, order: index}
        }
      }
    }
  end
end
