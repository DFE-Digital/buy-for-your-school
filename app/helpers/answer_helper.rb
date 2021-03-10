# frozen_string_literal: true

module AnswerHelper
  def human_readable_option(string:)
    string.tr("_", " ").capitalize
  end

  def machine_readable_option(string:)
    string.parameterize(separator: "_")
  end
end
