class CreateJourneyStep
  class UnexpectedContentfulModel < StandardError; end

  class UnexpectedContentfulStepType < StandardError; end

  ALLOWED_CONTENTFUL_MODELS = %w[question].freeze
  ALLOWED_CONTENTFUL_QUESTION_TYPES = ["radios", "short_text", "long_text"].freeze

  attr_accessor :journey, :contentful_entry
  def initialize(journey:, contentful_entry:)
    self.journey = journey
    self.contentful_entry = contentful_entry
  end

  def call
    if unexpected_contentful_model?
      send_rollbar_warning
      raise UnexpectedContentfulModel
    end

    if unexpected_contentful_step_type?
      send_rollbar_warning
      raise UnexpectedContentfulStepType
    end

    step = Step.create(
      title: title,
      help_text: help_text,
      contentful_type: step_type,
      options: options,
      raw: raw,
      journey: journey
    )

    journey.update(next_entry_id: next_entry_id)

    step
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
    ALLOWED_CONTENTFUL_QUESTION_TYPES.include?(step_type)
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

  def options
    return nil unless contentful_entry.respond_to?(:options)
    contentful_entry.options
  end

  def step_type
    contentful_entry.type.tr(" ", "_")
  end

  def raw
    contentful_entry.raw
  end

  def next_entry_id
    return nil unless contentful_entry.respond_to?(:next)
    contentful_entry.next.id
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
      allowed_step_types: ALLOWED_CONTENTFUL_QUESTION_TYPES.join(", ")
    )
  end
end
