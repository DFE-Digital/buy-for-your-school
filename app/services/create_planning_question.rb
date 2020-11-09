class CreatePlanningQuestion
  class UnexpectedContentType < StandardError; end

  ALLOWED_CONTENTFUL_CONTENT_TYPES = %w[question].freeze

  attr_accessor :plan, :contentful_entry
  def initialize(plan:, contentful_entry:)
    self.plan = plan
    self.contentful_entry = contentful_entry
  end

  def call
    if unexpected_question_type?
      send_rollbar_warning
      raise UnexpectedContentType
    end

    question = Question.create(
      title: title,
      help_text: help_text,
      contentful_type: contentful_type,
      options: options,
      raw: raw,
      plan: plan
    )

    plan.update(next_entry_id: next_entry_id)

    [question, Answer.new]
  end

  private

  def content_entry_id
    contentful_entry.id
  end

  def content_type
    contentful_entry.content_type.id
  end

  def expected_question_type?
    ALLOWED_CONTENTFUL_CONTENT_TYPES.include?(content_type)
  end

  def unexpected_question_type?
    !expected_question_type?
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

  def contentful_type
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
      "An unexpected Entry type was found instead of a #{ALLOWED_CONTENTFUL_CONTENT_TYPES.join(", ")}",
      contentful_url: ENV["CONTENTFUL_URL"],
      contentful_space_id: ENV["CONTENTFUL_SPACE"],
      contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
      contentful_entry_id: content_entry_id,
      content_type: content_type,
      allowed_content_types: ALLOWED_CONTENTFUL_CONTENT_TYPES.join(", ")
    )
  end
end
