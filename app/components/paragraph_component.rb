# frozen_string_literal: true

# @para text can be a string or an array, in which case a paragraph is rendered
# for each element
class ParagraphComponent < ViewComponent::Base
  def initialize(text:)
    @texts = [text].flatten
  end
end
