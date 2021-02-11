class ToggleAdditionalSteps
  attr_accessor :journey, :step
  def initialize(step:)
    self.journey = step.journey
    self.step = step
  end

  def call
    return unless additional_step_rule

    check_to_show_additional_step!
    check_to_hide_additional_step!
  end

  private

  def additional_step_rule
    step.additional_step_rule
  end

  def answer
    step.answer
  end

  def matching_answer?
    additional_step_rule["required_answer"].downcase == answer.response.downcase
  end

  def additional_step
    journey.steps.find_by(contentful_id: additional_step_rule["question_identifier"])
  end

  def check_to_show_additional_step!
    return unless matching_answer?

    additional_step.update(hidden: false)
  end

  def check_to_hide_additional_step!
    return if matching_answer?

    additional_step.update(hidden: true)
  end
end
