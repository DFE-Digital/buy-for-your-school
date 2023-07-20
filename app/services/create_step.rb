# Convert a {Contentful::Entry} into a {Step}
# Steps may have different fields available depending on their type.
#
class CreateStep
  include InsightsTrackable

  class UnexpectedContentfulModel < StandardError; end

  class UnexpectedContentfulStepType < StandardError; end

  # Steps are either Questions or Statements
  #
  # @return [Array<String>]
  ALLOWED_CONTENTFUL_MODELS = %w[
    question
    statement
  ].freeze

  # Contentful Question Model defined types
  #
  # @return [Array<String>]
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
  # @return [Array<String>]
  ALLOWED_CONTENTFUL_STATEMENT_TYPES = %w[
    markdown
  ].freeze

  ALLOWED_STEP_TYPES = ALLOWED_CONTENTFUL_QUESTION_TYPES + ALLOWED_CONTENTFUL_STATEMENT_TYPES

  # @param task [Task] persisted task
  # @param contentful_step [Contentful::Entry] Contentful Client object
  # @param order [Integer] position within the task
  #
  def initialize(task:, contentful_step:, order:)
    @task = task
    @contentful_step = contentful_step
    @order = order
  end

  # @raise [UnexpectedContentfulModel, UnexpectedContentfulStepType]
  #
  # @return [Step]
  def call
    if unexpected_contentful_model?
      track_error("CreateStep/UnexpectedContentfulModel")
      raise UnexpectedContentfulModel, content_model
    end

    if unexpected_step_type?
      track_error("CreateStep/UnexpectedContentfulStepType")
      raise UnexpectedContentfulStepType, step_type
    end

    create_step
  end

private

  # @return [Step]
  def create_step
    Step.create!(
      title:,
      help_text:,
      body:,
      contentful_id: content_entry_id,
      contentful_model: content_model,
      contentful_type: step_type,
      options:,
      criteria:,
      primary_call_to_action_text:,
      skip_call_to_action_text:,
      hidden: hidden?,
      additional_step_rules:,
      raw:,
      task: @task,
      order: @order,
    )
  end

  # @return [String] 1QdzZOVfL8x1d9Q9FA0u66
  def content_entry_id
    @contentful_step.id
  end

  # @return [String] question, statement
  def content_model
    @contentful_step.content_type.id
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
    @contentful_step.fields[:title]
  end

  # Used by questions
  #
  # @return [Nil, String]
  def help_text
    @contentful_step.fields[:help_text]
  end

  # Used by statements
  #
  # @return [Nil, String]
  def body
    @contentful_step.fields[:body]
  end

  # Used by radio and checkbox questions
  #
  # @return [Nil, String]
  def options
    @contentful_step.fields[:extended_options]
  end

  # Custom question validation
  #
  # @example
  #   criteria => { lower => "", upper => "", message => "" }
  #
  # @return [Nil, Hash<String>]
  def criteria
    @contentful_step.fields[:criteria]
  end

  # @return [String]
  def step_type
    # TODO: Make all step types snake_case in Contentful
    @contentful_step.fields[:type]&.tr(" ", "_")
  end

  # @see https://design-system.service.gov.uk/components/button/
  #
  # @return [Nil, String]
  def primary_call_to_action_text
    @contentful_step.fields[:primary_call_to_action]
  end

  # @see https://design-system.service.gov.uk/components/button/
  #
  # @return [Nil, String]
  def skip_call_to_action_text
    @contentful_step.fields[:skip_call_to_action]
  end

  # Determines if this step should be hidden in the task list.
  # Applies to steps dependent on answers of other steps.
  #
  # @return [Boolean]
  def hidden?
    !@contentful_step.fields.fetch(:always_show_the_user, true)
  end

  # @return [Nil, Array<Hash>]
  def additional_step_rules
    @contentful_step.fields[:show_additional_question]
  end

  # @example
  #   {
  #     "sys": {
  #       "id": "checkboxes-question",
  #       "contentType": {
  #         "sys": {
  #           "type": "Link",
  #           "linkType": "ContentType",
  #           "id": "question"
  #         }
  #       }
  #     },
  #     "fields": {
  #       "type": "checkboxes",
  #       "title": "Everyday services that are required and need to be considered",
  #       "extendedOptions": [
  #         { "value": "Breakfast" },
  #         { "value": "Morning break" },
  #         { "value": "Lunch" },
  #         { "value": "Dinner" }
  #       ],
  #       "alwaysShowTheUser": true,
  #       "showAdditionalQuestion": [
  #         {
  #           "required_answer": "Lunch",
  #           "question_identifiers": ["lunch-additional-question"]
  #         }
  #       ]
  #     }
  #   }
  #
  # @return [Hash] JSON
  def raw
    @contentful_step.raw
  end

  def tracking_base_properties
    super.merge(
      contentful_space_id: @contentful_step.space.id,
      contentful_environment: @contentful_step.environment.id,
      contentful_entry_id: content_entry_id,
      content_model:,
      step_type:,
      allowed_content_models: ALLOWED_CONTENTFUL_MODELS.join(", "),
      allowed_step_types: ALLOWED_STEP_TYPES.join(", "),
    )
  end
end
