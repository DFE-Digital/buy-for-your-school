class ToggleAdditionalSteps
  attr_accessor :journey, :step
  def initialize(step:)
    self.journey = step.journey
    self.step = step
  end

  def call
    return unless additional_step_rule

    check_to_show_additional_steps! if additional_step.hidden?
    check_to_hide_additional_steps! unless additional_step.hidden?
  end

  private

  def answer
    step.answer
  end

  def journey_steps
    @journey_steps ||= journey.steps
  end

  def additional_step_rule
    step.additional_step_rule
  end

  def additional_step_id
    additional_step_rule["question_identifier"]
  end

  def additional_step
    journey_steps.find_by(contentful_id: additional_step_id)
  end

  def matching_answer?
    expected_answer = additional_step_rule["required_answer"].downcase
    case answer.response.class.name
    when "Array"
      answer.response.map(&:downcase).include?(expected_answer)
    else
      expected_answer == answer.response.downcase
    end
  end

  def check_to_show_additional_steps!
    return unless matching_answer?

    recursively_toggle_additional_steps!(next_step_id: additional_step_id, hidden_state: false)
  end

  def check_to_hide_additional_steps!
    return if matching_answer?

    recursively_toggle_additional_steps!(next_step_id: additional_step_id, hidden_state: true)
  end

  def recursively_toggle_additional_steps!(next_step_id:, hidden_state:)
    if next_step_id

      next_step = journey_steps.find_by(contentful_id: next_step_id)
      next_step.update(hidden: hidden_state)

      recursively_toggle_additional_steps!(
        next_step_id: next_step.additional_step_rule&.fetch("question_identifier", nil),
        hidden_state: hidden_state
      )
    end
  end
end
