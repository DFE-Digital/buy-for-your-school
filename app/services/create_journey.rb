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
      liquid_template: category.combined_specification_template
    )

    journey.save!

    contentful_sections.each do |contentful_section|
      section = CreateSection.new(journey: journey, contentful_section: contentful_section).call

      contentful_tasks = GetTasksFromSection.new(section: contentful_section).call
      contentful_tasks.each do |contentful_task|
        task = CreateTask.new(section: section, contentful_task: contentful_task).call

        question_entries = GetStepsFromTask.new(task: contentful_task).call
        question_entries.each do |entry|
          CreateJourneyStep.new(
            contentful_entry: entry, task: task
          ).call
        end
      end
    end

    journey
  end
end
