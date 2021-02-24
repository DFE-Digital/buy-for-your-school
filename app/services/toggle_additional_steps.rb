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
    additional_step_rules.map { |rule|
      rule["question_identifier"]
    }.flatten
  end

  def additional_steps_to_show
    matching_next_step_ids = step.additional_step_rules.map { |rule|
      rule.fetch("question_identifier", nil) if step.answer && matching_answer?(a: rule["required_answer"], b: step.answer.response)
    }.flatten
    journey_steps.where(contentful_id: matching_next_step_ids)
  end

  def additional_steps_to_hide
    non_matching_next_step_ids = step.additional_step_rules.map { |rule|
      rule.fetch("question_identifier", nil) unless matching_answer?(a: rule["required_answer"], b: step.answer.response)
    }.flatten
    journey_steps.where(contentful_id: non_matching_next_step_ids)
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
    recursively_show_additional_steps!(current_step: step, next_steps: additional_steps_to_show)
  end

  def check_to_hide_additional_steps!
    recursively_hide_additional_steps!(next_steps: additional_steps_to_hide)
  end

  def recursively_hide_additional_steps!(next_steps:)
    if next_steps
      next_steps.update_all(hidden: true)

      next_steps.map { |next_step|
        next unless next_step.additional_step_rules

        all_next_step_ids = next_step.additional_step_rules.map { |rule|
          rule.fetch("question_identifier", nil)
        }
        all_next_steps = journey_steps.where(contentful_id: all_next_step_ids)

        recursively_hide_additional_steps!(
          next_steps: all_next_steps
        )
      }
    end
  end

  def recursively_show_additional_steps!(current_step:, next_steps:)
    return unless current_step.answer && current_step.additional_step_rules

    if next_steps
      next_steps.update_all(hidden: false)

      next_steps.map { |next_step|
        next unless next_step.additional_step_rules

        matching_next_step_ids = next_step.additional_step_rules.map { |rule|
          rule.fetch("question_identifier", nil) if next_step.answer && matching_answer?(a: rule["required_answer"], b: next_step.answer.response)
        }
        matching_next_steps = journey_steps.where(contentful_id: matching_next_step_ids)

        recursively_show_additional_steps!(
          current_step: next_step,
          next_steps: matching_next_steps
        )
      }
    end
  end
end
