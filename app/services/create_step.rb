# CreateStep service is responsible for constructing a {Step} for the given task.
class CreateStep
  class UnexpectedContentfulModel < StandardError; end

  class UnexpectedContentfulStepType < StandardError; end

  ALLOWED_CONTENTFUL_MODELS = %w[
    question
    staticContent
  ].freeze

  ALLOWED_CONTENTFUL_ENTRY_TYPES = %w[
    radios
    short_text
    long_text
    paragraphs
    single_date
    checkboxes
    number
    currency
  ].freeze

  attr_accessor :task, :contentful_entry, :order

  def initialize(task:, contentful_entry:, order:)
    self.task = task
    self.contentful_entry = contentful_entry
    self.order = order
  end

  # Creates and persists a new Step.
  #
  # This relies on the passed-in `contentful_entry` to construct the object.
  #
  # @return [Step]
  def call
    if unexpected_contentful_model?
      send_rollbar_warning
      raise UnexpectedContentfulModel
    end

    if unexpected_contentful_step_type?
      send_rollbar_warning
      raise UnexpectedContentfulStepType
    end

    Step.create!(
      title: title,
      help_text: help_text,
      body: body,
      contentful_id: content_entry_id,
      contentful_model: content_model,
      contentful_type: step_type,
      options: options,
      primary_call_to_action_text: primary_call_to_action_text,
      skip_call_to_action_text: skip_call_to_action_text,
      hidden: hidden,
      additional_step_rules: additional_step_rules,
      raw: raw,
      task: task,
      order: order,
    )
  end

private

  def content_entry_id
    contentful_entry.id
  end

  def content_model
    contentful_entry.content_type.id
  end

  def expected_contentful_model?
    ALLOWED_CONTENTFUL_MODELS.include?(content_model)
  end

  def unexpected_contentful_model?
    !expected_contentful_model?
  end

  def expected_contentful_step_type?
    ALLOWED_CONTENTFUL_ENTRY_TYPES.include?(step_type)
  end

  def unexpected_contentful_step_type?
    !expected_contentful_step_type?
  end

  def title
    contentful_entry.title
  end

  def help_text
    return nil unless contentful_entry.respond_to?(:help_text)

    contentful_entry.help_text
  end

  def body
    return nil unless contentful_entry.respond_to?(:body)

    contentful_entry.body
  end

  def options
    return nil unless contentful_entry.respond_to?(:extended_options)

    contentful_entry.extended_options
  end

  def step_type
    contentful_entry.type.tr(" ", "_")
  end

  # @see https://design-system.service.gov.uk/components/button/
  def primary_call_to_action_text
    return nil unless contentful_entry.respond_to?(:primary_call_to_action)

    contentful_entry.primary_call_to_action
  end

  # @see https://design-system.service.gov.uk/components/button/
  def skip_call_to_action_text
    return nil unless contentful_entry.respond_to?(:skip_call_to_action)

    contentful_entry.skip_call_to_action
  end

  def hidden
    return false unless contentful_entry.respond_to?(:always_show_the_user)
    return false if contentful_entry.always_show_the_user.nil?

    !contentful_entry.always_show_the_user
  end

  def additional_step_rules
    return nil unless contentful_entry.respond_to?(:show_additional_question)

    contentful_entry.show_additional_question
  end

  def raw
    contentful_entry.raw
  end

  def send_rollbar_warning
    Rollbar.warning(
      "An unexpected Contentful type was found",
      contentful_url: ENV["CONTENTFUL_URL"],
      contentful_space_id: ENV["CONTENTFUL_SPACE"],
      contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
      contentful_entry_id: content_entry_id,
      content_model: content_model,
      step_type: step_type,
      allowed_content_models: ALLOWED_CONTENTFUL_MODELS.join(", "),
      allowed_step_types: ALLOWED_CONTENTFUL_ENTRY_TYPES.join(", "),
    )
  end
end
