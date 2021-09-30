# frozen_string_literal: true

# String coercion helpers
#
# @see AnswersController#further_information_params
# @see RadioAnswerPresenter
# @see CheckboxesAnswerPresenter
#
# @example
#
#   `name="answer[No thank you]"` to `name="answer[no_thank_you_further_information]"`
#
module AnswerHelper
  # Revert a string from snake_case
  #
  # @param string [String]
  #
  # @return [String]
  def human_readable_option(string:)
    string.tr("_", " ").capitalize
  end

  # Convert a string to snake_case
  #
  # @param string [String]
  #
  # @return [String]
  def machine_readable_option(string:)
    string.parameterize(separator: "_")
  end
end
