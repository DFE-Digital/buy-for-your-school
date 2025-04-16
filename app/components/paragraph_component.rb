# frozen_string_literal: true

# @para text can be a string or an array, in which case a paragraph is rendered
# for each element
class ParagraphComponent < ViewComponent::Base
  def initialize(text:, size: :m)
    @texts = [text].flatten
    @class = {
      s: "govuk-body-s",
      m: "govuk-body",
      l: "govuk-body-l",
    }[size]
  end
end
