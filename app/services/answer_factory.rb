# AnswerFactory is responsible for determining the right answer type for a {Step}.
class AnswerFactory
  class UnexpectedQuestionType < StandardError; end

  attr_accessor :step

  def initialize(step:)
    self.step = step
  end

  # Returns the right answer type based on the provided {Step} `contentful_type`.
  #
  # @return [Mixed]
  def call
    case step.contentful_type
    when "radios" then RadioAnswer.new
    when "number" then NumberAnswer.new
    when "currency" then CurrencyAnswer.new
    when "short_text" then ShortTextAnswer.new
    when "long_text" then LongTextAnswer.new
    when "single_date" then SingleDateAnswer.new
    when "checkboxes" then CheckboxAnswers.new
    else raise UnexpectedQuestionType, "Trying to create answer for unknown question type #{step.contentful_type}"
    end
  end
end
