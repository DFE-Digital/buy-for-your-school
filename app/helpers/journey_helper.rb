# frozen_string_literal: true

module JourneyHelper
  def section_group_with_steps(journey:, steps:)
    step_lookup = steps.group_by(&:contentful_id)

    journey.section_groups.each do |section|
      ordered_step_objects = section["steps"].each_with_object([]) { |step, result|
        result[step["order"]] = step_lookup[step["contentful_id"]].first
      }
      section["steps"] = ordered_step_objects.compact
    end
  end
end
