class CreatePlanningQuestion
  class UnexpectedContentfulModel < StandardError; end
  class UnexpectedContentfulQuestionType < StandardError; end

  ALLOWED_CONTENTFUL_MODELS = %w[question].freeze
  ALLOWED_CONTENTFUL_QUESTION_TYPES = ["radios", "short_text", "long_text"].freeze

  attr_accessor :plan, :contentful_entry
  def initialize(plan:, contentful_entry:)
    self.plan = plan
    self.contentful_entry = contentful_entry
  end

  def call
    if unexpected_contentful_model?
      send_rollbar_warning
      raise UnexpectedContentfulModel
    end

    if unexpected_contentful_question_type?
      send_rollbar_warning
      raise UnexpectedContentfulQuestionType
    end

    question = Question.create(
      title: title,
      help_text: help_text,
      contentful_type: question_type,
      options: options,
      raw: raw,
      plan: plan
    )

    plan.update(next_entry_id: next_entry_id)

    [question, AnswerFactory.new(question: question).call]
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

  def expected_contentful_question_type?
    ALLOWED_CONTENTFUL_QUESTION_TYPES.include?(question_type)
  end

  def unexpected_contentful_question_type?
    !expected_contentful_question_type?
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

  def question_type
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
      question_type: question_type,
      allowed_content_models: ALLOWED_CONTENTFUL_MODELS.join(", "),
      allowed_question_types: ALLOWED_CONTENTFUL_QUESTION_TYPES.join(", ")
    )
  end
end
