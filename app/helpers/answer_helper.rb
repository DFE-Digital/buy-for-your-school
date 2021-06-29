# frozen_string_literal: true

# AnswerHelper provides utility methods to convert further information keys between
# human-readable and machine-readable representations.
#
# e.g. `name="answer[No thank you]"` to `name="answer[no_thank_you_further_information]"`
module AnswerHelper
  # Converts a key with underscores to a human-readable representation.
  #
  # @param [String] string
  #
  # @return [String]
  def human_readable_option(string:)
    string.tr("_", " ").capitalize
  end

  # Converts a human-readable string to a machine-readable representation with underscores.
  #
  # @param [String] string
  #
  # @return [String]
  def machine_readable_option(string:)
    string.parameterize(separator: "_")
  end
end
