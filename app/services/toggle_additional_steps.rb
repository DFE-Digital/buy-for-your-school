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

  def matching_answer?(a:, b:)
    expected_answer = a.downcase
    case b.class.name
    when "Array"
      b.map(&:downcase).include?(expected_answer)
    else
      expected_answer == b.downcase
    end
  end

  def check_to_show_additional_steps!
    recursively_show_additional_steps!(current_step: step, next_step_id: additional_step_id)
  end

  def check_to_hide_additional_steps!
    return if matching_answer?(a: step.additional_step_rule["required_answer"], b: step.answer.response)

    recursively_hide_additional_steps!(current_step: step, next_step_id: additional_step_id)
  end

  def recursively_hide_additional_steps!(current_step:, next_step_id:)
    if next_step_id

      next_step = journey_steps.find_by(contentful_id: next_step_id)
      next_step.update(hidden: true)

      recursively_hide_additional_steps!(
        current_step: next_step,
        next_step_id: next_step.additional_step_rule&.fetch("question_identifier", nil)
      )
    end
  end

  def recursively_show_additional_steps!(current_step:, next_step_id:)
    return unless current_step.answer && current_step.additional_step_rule

    if next_step_id
      return unless matching_answer?(a: current_step.additional_step_rule["required_answer"], b: current_step.answer.response)

      next_step = journey_steps.find_by(contentful_id: next_step_id)
      next_step.update(hidden: false)

      recursively_show_additional_steps!(
        current_step: next_step,
        next_step_id: next_step.additional_step_rule&.fetch("question_identifier", nil)
      )
    end
  end
end
