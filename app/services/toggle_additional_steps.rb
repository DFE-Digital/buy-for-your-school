# ToggleAdditionalSteps service is responsible for showing and hiding additional steps.
class ToggleAdditionalSteps
  attr_accessor :journey, :step

  def initialize(step:)
    self.journey = step.journey
    self.step = step
  end

  def call
    return unless additional_step_rules

    recursively_hide_additional_steps!(next_steps: additional_steps_to_hide)
    recursively_show_additional_steps!(current_step: step, next_steps: additional_steps_to_show(step: step))
  end

private

  def journey_steps
    @journey_steps ||= journey.steps
  end

  def additional_step_rules
    step.additional_step_rules
  end

  # Unused
  #
  # def additional_step_ids
  #   additional_step_rules.map { |rule|
  #     rule["question_identifiers"]
  #   }.flatten
  # end

  def additional_steps_to_show(step:)
    matching_next_step_ids = step.additional_step_rules.map { |rule|
      rule.fetch("question_identifiers", nil) if step.answer && matching_answer?(expected: rule["required_answer"], response: step.answer.response)
    }.flatten
    journey_steps.where(contentful_id: matching_next_step_ids)
  end

  def additional_steps_to_hide
    non_matching_next_step_ids = step.additional_step_rules.map { |rule|
      rule.fetch("question_identifiers", nil) unless matching_answer?(expected: rule["required_answer"], response: step.answer.response)
    }.flatten
    journey_steps.where(contentful_id: non_matching_next_step_ids)
  end

  def matching_answer?(expected:, response:)
    expected_answer = expected.downcase
    case response.class.name
    when "Array"
      response.map(&:downcase).include?(expected_answer)
    else
      expected_answer == response.downcase
    end
  end

  def recursively_hide_additional_steps!(next_steps:)
    if next_steps
      next_steps.update_all(hidden: true)

      next_steps.map do |next_step|
        next unless next_step.additional_step_rules

        all_next_step_ids = next_step.additional_step_rules.map { |rule|
          rule.fetch("question_identifiers", nil)
        }.flatten
        all_next_steps = journey_steps.where(contentful_id: all_next_step_ids)

        recursively_hide_additional_steps!(
          next_steps: all_next_steps,
        )
      end
    end
  end

  def recursively_show_additional_steps!(current_step:, next_steps:)
    return unless current_step.answer && current_step.additional_step_rules

    if next_steps
      next_steps.update_all(hidden: false)

      next_steps.map do |next_step|
        next unless next_step.additional_step_rules

        recursively_show_additional_steps!(
          current_step: next_step,
          next_steps: additional_steps_to_show(step: next_step),
        )
      end
    end
  end
end
