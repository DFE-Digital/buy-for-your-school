# Show or Hide additional steps after a valid answer
#
# @see SaveAnswer
#
# @example
#   step.additional_step_rules => [{"required_answer"=>"Red", "question_identifiers"=>["123", "456"]}]
#
class ToggleAdditionalSteps
  # @return [Step]
  attr_reader :step
  # @return [Journey]
  attr_reader :journey

  # @param step [Step]
  def initialize(step:)
    @journey = step.journey
    @step = step
  end

  # Refresh task step_tally once toggling is complete
  #
  # @return [Boolean]
  #
  def call
    return false unless step.additional_step_rules?

    recursively_hide_additional_steps!(next_steps: additional_steps_to_hide)
    recursively_show_additional_steps!(current_step: step, next_steps: additional_steps_to_show(step:))

    step.task.save!
  end

private

  # @return [ActiveRecord_Associations]
  def journey_steps
    @journey_steps ||= journey.steps
  end

  # @param expected [String]
  # @param response [String, Array<String>]
  #
  # @return [Boolean]
  def matching_answer?(expected:, response:)
    Array(response).any? { |res| res.casecmp(expected).zero? }
  end

  # @param step [Step]
  #
  # @return [Step::ActiveRecord_AssociationRelation]
  def additional_steps_to_show(step:)
    matching_next_step_ids = step.additional_step_rules.flat_map do |rule|
      next unless step.answer && matching_answer?(expected: rule["required_answer"], response: step.answer.response)

      rule.fetch("question_identifiers", nil)
    end

    journey_steps.where(contentful_id: matching_next_step_ids.compact)
  end

  # @return [Step::ActiveRecord_AssociationRelation]
  def additional_steps_to_hide
    non_matching_next_step_ids = step.additional_step_rules.flat_map do |rule|
      next if matching_answer?(expected: rule["required_answer"], response: step.answer.response)

      rule.fetch("question_identifiers", nil)
    end

    journey_steps.where(contentful_id: non_matching_next_step_ids.compact)
  end

  # @param next_steps [Step::ActiveRecord_AssociationRelation]
  #
  # @return [False, Array<Step>]
  def recursively_hide_additional_steps!(next_steps:)
    return false unless next_steps

    next_steps.update_all(hidden: true)

    next_steps.each do |next_step|
      next unless next_step.additional_step_rules

      all_next_step_ids = next_step.additional_step_rules.flat_map do |rule|
        rule.fetch("question_identifiers", nil)
      end

      all_next_steps = journey_steps.where(contentful_id: all_next_step_ids.compact)

      recursively_hide_additional_steps!(next_steps: all_next_steps)
    end
  end

  # @param current_step [Step]
  # @param next_steps [Step::ActiveRecord_AssociationRelation]
  #
  # @return [False, Array<Step>]
  def recursively_show_additional_steps!(current_step:, next_steps:)
    return false unless next_steps && (current_step.answer && current_step.additional_step_rules)

    next_steps.update_all(hidden: false)

    next_steps.each do |next_step|
      next unless next_step.additional_step_rules

      recursively_show_additional_steps!(
        current_step: next_step,
        next_steps: additional_steps_to_show(step: next_step),
      )
    end
  end
end
