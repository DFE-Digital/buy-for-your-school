# Convert a {Contentful::Entry} into a {Step}
#
class CreateStep
  class UnexpectedContentfulModel < StandardError; end

  class UnexpectedContentfulStepType < StandardError; end

  # Steps are either Questions or Statements
  #
  ALLOWED_CONTENTFUL_MODELS = %w[
    question
    statement
  ].freeze

  # Contentful Question Model defined types
  #
  ALLOWED_CONTENTFUL_QUESTION_TYPES = %w[
    long_text
    short_text
    checkboxes
    radios
    currency
    number
    single_date
  ].freeze

  # Contentful Statement Model defined types
  #
  ALLOWED_CONTENTFUL_STATEMENT_TYPES = %w[
    markdown
  ].freeze

  ALLOWED_STEP_TYPES = ALLOWED_CONTENTFUL_QUESTION_TYPES + ALLOWED_CONTENTFUL_STATEMENT_TYPES

  attr_accessor :task, :contentful_entry, :order

  # @param task [Task] persisted task
  # @param contentful_entry [Contentful::Entry] Contentful Client object
  # @param order [Integer] position within the task
  #
  def initialize(task:, contentful_entry:, order:)
    self.task = task
    self.contentful_entry = contentful_entry
    self.order = order
  end

  # @return [Step]
  def call
    if unexpected_contentful_model?
      send_rollbar_warning
      # TODO: pass unexpected model to the exception so it is logged
      raise UnexpectedContentfulModel
    end

    if unexpected_step_type?
      send_rollbar_warning
      # TODO: pass unexpected step type to the exception so it is logged
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
      hidden: hidden?,
      additional_step_rules: additional_step_rules,
      raw: raw,
      task: task,
      order: order,
    )
  end

private

  # @return [String]
  def content_entry_id
    contentful_entry.id
  end

  # @return [String] question, statement
  def content_model
    contentful_entry.content_type.id
  end

  # @return [Boolean]
  def expected_contentful_model?
    ALLOWED_CONTENTFUL_MODELS.include?(content_model)
  end

  # @return [Boolean]
  def unexpected_contentful_model?
    !expected_contentful_model?
  end

  # @return [Boolean]
  def expected_step_type?
    ALLOWED_STEP_TYPES.include?(step_type)
  end

  # @return [Boolean]
  def unexpected_step_type?
    !expected_step_type?
  end

  # @return [String]
  def title
    contentful_entry.title
  end

  # @return [Nil, String]
  def help_text
    return nil unless contentful_entry.respond_to?(:help_text)

    contentful_entry.help_text
  end

  # @return [Nil, String]
  def body
    return nil unless contentful_entry.respond_to?(:body)

    contentful_entry.body
  end

  # @return [Nil, String]
  def options
    return nil unless contentful_entry.respond_to?(:extended_options)

    contentful_entry.extended_options
  end

  # @return [String]
  def step_type
    contentful_entry.type.tr(" ", "_")
  end

  # @see https://design-system.service.gov.uk/components/button/
  # @return [Nil, String]
  def primary_call_to_action_text
    return nil unless contentful_entry.respond_to?(:primary_call_to_action)

    contentful_entry.primary_call_to_action
  end

  # @see https://design-system.service.gov.uk/components/button/
  # @return [Nil, String]
  def skip_call_to_action_text
    return nil unless contentful_entry.respond_to?(:skip_call_to_action)

    contentful_entry.skip_call_to_action
  end

  # @return [Boolean]
  def hidden?
    return false unless contentful_entry.respond_to?(:always_show_the_user)
    return false if contentful_entry.always_show_the_user.nil?

    !contentful_entry.always_show_the_user
  end

  # @return [Nil, Array<Hash>]
  def additional_step_rules
    return nil unless contentful_entry.respond_to?(:show_additional_question)

    contentful_entry.show_additional_question
  end

  # @return [String]
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
      allowed_step_types: ALLOWED_STEP_TYPES.join(", "),
    )
  end
end
