class CheckboxesAnswerPresenter < BasePresenter
  include AnswerHelper

  # @return [String, nil]
  def response
    super.reject(&:blank?)
  end

  # @return [String]
  def concatenated_response
    return nil if response.empty?

    response.join(", ")
  end

  # @return [Hash]
  def to_param
    {
      response: response,
      concatenated_response: concatenated_response,
      skipped: skipped,
      selected_answers: selected_answers,
    }
  end

private

  # @return [Array]
  def selected_answers
    return [] if response.empty?

    response.each_with_object([]) do |human_readable_choice, array|
      machine_readable_key = machine_readable_option(string: human_readable_choice).to_sym
      matching_further_information = further_information&.fetch("#{machine_readable_key}_further_information", nil)

      array << {
        machine_value: machine_readable_key,
        human_value: human_readable_choice,
        further_information: matching_further_information,
      }
    end
  end
end
