class RecordAction
  class UnexpectedActionType < StandardError; end

  attr_accessor :action_type, :journey_id, :user_id, :contentful_category_id, :contentful_section_id, :contentful_task_id, :contentful_step_id, :data

  ALLOWED_ACTION_TYPES = %w[
    begin_journey
    view_journey
  ].freeze

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
    self.action_type = action
    self.journey_id = journey_id
    self.user_id = user_id
    self.contentful_category_id = contentful_category_id
    self.contentful_section_id = contentful_section_id
    self.contentful_task_id = contentful_task_id
    self.contentful_step_id = contentful_step_id
    self.data = data
  end

  def call
    if unexpected_action_type?
      send_rollbar_warning
      raise UnexpectedActionType
    end

    ActivityLogItem.create(
      action: action_type,
      journey_id: journey_id,
      user_id: user_id,
      contentful_category_id: contentful_category_id,
      contentful_section_id: contentful_section_id,
      contentful_task_id: contentful_task_id,
      contentful_step_id: contentful_step_id,
      data: data
    )
  end

  private

  def valid_action_type?
    ALLOWED_ACTION_TYPES.include?(action_type)
  end

  def unexpected_action_type?
    !valid_action_type?
  end

  def send_rollbar_warning
    Rollbar.warning(
      "An attempt was made to log an action with an invalid type",
      action: action_type,
      journey_id: journey_id,
      user_id: user_id,
      contentful_category_id: contentful_category_id,
      contentful_section_id: contentful_section_id,
      contentful_task_id: contentful_task_id,
      contentful_step_id: contentful_step_id,
      data: data,
      allowed_action_types: ALLOWED_ACTION_TYPES.join(", ")
    )
  end
end
