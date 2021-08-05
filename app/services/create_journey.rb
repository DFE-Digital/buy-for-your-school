# Create {Journey} using entries returned by {Content::Client}
#
# @see JourneysController#create
# @see CreateSection#call
# @see CreateTask#call
# @see CreateStep#call
#
class CreateJourney
  # @param user [User]
  # @param category [Category]
  #
  def initialize(user:, category:)
    @user = user
    @category = category
  end

  # @return [Journey]
  def call
    journey = Journey.new(category: @category, user: @user)
    journey.save!

    # Contentful::Entry[category]
    contentful_category = GetCategory.new(category_entry_id: @category.contentful_id).call
    # Contentful::Entry[section]
    contentful_sections = GetSectionsFromCategory.new(category: contentful_category).call

    contentful_sections.each_with_index do |contentful_section, section_index|
      # Section
      section = CreateSection.new(
        journey: journey,
        contentful_section: contentful_section,
        order: section_index,
      ).call

      # Contentful::Entry[task]
      contentful_tasks = GetTasksFromSection.new(section: contentful_section).call

      contentful_tasks.each_with_index do |contentful_task, task_index|
        # Task
        task = CreateTask.new(
          section: section,
          contentful_task: contentful_task,
          order: task_index,
        ).call

        # Contentful::Entry[step]
        contentful_steps = GetStepsFromTask.new(task: contentful_task).call

        contentful_steps.each_with_index do |entry, step_index|
          # Step
          CreateStep.new(
            contentful_step: entry,
            task: task,
            order: step_index,
          ).call
        end
      end
    end

    journey
  end
end
