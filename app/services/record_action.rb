# Track user activity in controller actions
#
# @see ActivityLogItem
class RecordAction
  ACTION_TYPES = %w[
    begin_journey
    view_journey
    begin_task
    view_task
    begin_step
    view_step
    skip_step
    save_answer
    acknowledge_statement
    update_answer
    view_specification
  ].freeze

  # @param action [String]
  # @param journey_id [String]
  # @param user_id [String]
  # @param contentful_category_id [String]
  # @param contentful_category [String]
  # @param contentful_section_id [String]
  # @param contentful_section [String]
  # @param contentful_task_id [String]
  # @param contentful_task [String]
  # @param contentful_step_id [String]
  # @param contentful_step [String]
  # @param data [Hash]
  #
  def initialize(
    action:,
    journey_id:,
    user_id:,
    contentful_category_id: nil,
    contentful_category: nil,
    contentful_section_id: nil,
    contentful_section: nil,
    contentful_task_id: nil,
    contentful_task: nil,
    contentful_step_id: nil,
    contentful_step: nil,
    data: nil
  )
    @action_type = action
    @journey_id = journey_id
    @user_id = user_id
    @contentful_category_id = contentful_category_id
    @contentful_category = contentful_category
    @contentful_section_id = contentful_section_id
    @contentful_section = contentful_section
    @contentful_task_id = contentful_task_id
    @contentful_task = contentful_task
    @contentful_step_id = contentful_step_id
    @contentful_step = contentful_step
    @data = data
  end

  # @raise [RecordAction::UnexpectedActionType]
  #
  # @return [ActivityLogItem]
  def call
    ActivityLogItem.create!(
      action: @action_type,
      journey_id: @journey_id,
      user_id: @user_id,
      contentful_category_id: @contentful_category_id,
      contentful_category: @contentful_category,
      contentful_section_id: @contentful_section_id,
      contentful_section: @contentful_section,
      contentful_task_id: @contentful_task_id,
      contentful_task: @contentful_task,
      contentful_step_id: @contentful_step_id,
      contentful_step: @contentful_step,
      data: @data,
    )
  end
end
