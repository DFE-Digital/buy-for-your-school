class CreatePlanningQuestion
  attr_accessor :plan
  def initialize(plan:)
    self.plan = plan
  end

  def call
    Question.create(
      title: contentful_response.dig("fields", "title"),
      help_text: contentful_response.dig("fields", "helpText"),
      contentful_type: contentful_response.dig("fields", "type"),
      options: contentful_response.dig("fields", "options"),
      raw: contentful_response,
      plan: plan
    )
  end

  private

  def contentful_response
    @contentful_response ||= GetContentfulEntry
      .new
      .call(entry_id: plan.next_entry_id)
  end
end
