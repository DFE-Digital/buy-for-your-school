# Track user activity in controller actions
#
# @see ActivityLogItem
class RecordAction
  class UnexpectedActionType < StandardError; end

  ACTION_TYPES = %w[
    begin_journey
    view_journey
    begin_task
    view_task
    begin_step
    view_step
    save_answer
    update_answer
    view_specification
  ].freeze

  # @param action [String]
  # @param journey_id [String]
  # @param user_id [String]
  # @param contentful_category_id [String]
  # @param contentful_section_id [String]
  # @param contentful_task_id [String]
  # @param contentful_step_id [String]
  # @param data [Hash]
  #
  def initialize(
    action:,
    journey_id:,
    user_id:,
    contentful_category_id: nil,
    contentful_section_id: nil,
    contentful_task_id: nil,
    contentful_step_id: nil,
    data: nil
  )
    @action_type = action
    @journey_id = journey_id
    @user_id = user_id
    @contentful_category_id = contentful_category_id
    @contentful_section_id = contentful_section_id
    @contentful_task_id = contentful_task_id
    @contentful_step_id = contentful_step_id
    @data = data
  end

  # @raise [RecordAction::UnexpectedActionType]
  #
  # @return [ActivityLogItem]
  def call
    if invalid_action?
      send_rollbar_warning
      raise UnexpectedActionType
    end

    ActivityLogItem.create!(
      action: @action_type,
      journey_id: @journey_id,
      user_id: @user_id,
      contentful_category_id: @contentful_category_id,
      contentful_section_id: @contentful_section_id,
      contentful_task_id: @contentful_task_id,
      contentful_step_id: @contentful_step_id,
      data: @data,
    )
  end

private

  def valid_action?
    ACTION_TYPES.include?(@action_type)
  end

  def invalid_action?
    !valid_action?
  end

  def send_rollbar_warning
    Rollbar.warning(
      "An attempt was made to log an action with an invalid type",
      action: @action_type,
      journey_id: @journey_id,
      user_id: @user_id,
      contentful_category_id: @contentful_category_id,
      contentful_section_id: @contentful_section_id,
      contentful_task_id: @contentful_task_id,
      contentful_step_id: @contentful_step_id,
      data: @data,
      allowed_action_types: ACTION_TYPES.join(", "),
    )
  end
end
