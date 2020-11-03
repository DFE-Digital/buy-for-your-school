class CreatePlanningQuestion
  class UnexpectedContentType < StandardError; end

  ALLOWED_CONTENTFUL_CONTENT_TYPES = %w[question].freeze

  attr_accessor :plan
  def initialize(plan:)
    self.plan = plan
  end

  def call
    if unexpected_question_type?
      send_rollbar_warning
      raise UnexpectedContentType
    end

    question = Question.create(
      title: contentful_response.dig("fields", "title"),
      help_text: contentful_response.dig("fields", "helpText"),
      contentful_type: contentful_response.dig("fields", "type"),
      options: contentful_response.dig("fields", "options"),
      raw: contentful_response,
      plan: plan
    )

    plan.update(next_entry_id: contentful_response.dig("fields", "next", "sys", "id"))

    question
  end

  private

  def content_entry_id
    contentful_response.dig("sys", "id")
  end

  def contentful_response
    @contentful_response ||= GetContentfulEntry
      .new(entry_id: plan.next_entry_id)
      .call
  end

  def content_type
    contentful_response.dig("sys", "contentType", "sys", "id")
  end

  def expected_question_type?
    ALLOWED_CONTENTFUL_CONTENT_TYPES.include?(content_type)
  end

  def unexpected_question_type?
    !expected_question_type?
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
