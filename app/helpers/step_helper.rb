# frozen_string_literal: true

module StepHelper
  def checkbox_options(array_of_options:)
    array_of_options.map { |option|
      OpenStruct.new(id: option.downcase, name: option.titleize)
    }
  end
end
