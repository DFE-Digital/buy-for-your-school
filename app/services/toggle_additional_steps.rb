class ToggleAdditionalSteps
  attr_accessor :journey, :step
  def initialize(step:)
    self.journey = step.journey
    self.step = step
  end

  def call
    return unless additional_step_rules

    check_to_show_additional_steps!
    check_to_hide_additional_steps!
  end

  private

  def answer
    step.answer
  end

  def journey_steps
    @journey_steps ||= journey.steps
  end

  def additional_step_rules
    step.additional_step_rules
  end

  def additional_step_ids
    additional_step_rules["question_identifier"]
  end

  def additional_step
    journey_steps.find_by(contentful_id: additional_step_ids)
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
    recursively_show_additional_steps!(current_step: step, next_step_ids: additional_step_ids)
  end

  def check_to_hide_additional_steps!
    return if matching_answer?(a: step.additional_step_rules["required_answer"], b: step.answer.response)

    recursively_hide_additional_steps!(next_step_ids: additional_step_ids)
  end

  def recursively_hide_additional_steps!(next_step_ids:)
    if next_step_ids.compact.present?
      next_steps = journey_steps.where(contentful_id: next_step_ids)
      next_steps.update_all(hidden: true)

      recursively_hide_additional_steps!(
        next_step_ids: next_steps.map { |next_step|
          next_step.additional_step_rules&.fetch("question_identifier", nil)
        }.flatten.compact
      )
    end
  end

  def recursively_show_additional_steps!(current_step:, next_step_ids:)
    return unless current_step.answer && current_step.additional_step_rules

    if next_step_ids
      return unless matching_answer?(a: current_step.additional_step_rules["required_answer"], b: current_step.answer.response)

      next_steps = journey_steps.where(contentful_id: next_step_ids)
      next_steps.update_all(hidden: false)

      next_steps.map { |next_step|
        recursively_show_additional_steps!(
          current_step: next_step,
          next_step_ids: next_step.additional_step_rules&.fetch("question_identifier", nil)
        )
      }
    end
  end
end
