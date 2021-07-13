# Select appropriate answer model for {Step} question
#
class AnswerFactory
  class UnexpectedQuestionType < StandardError; end

  attr_accessor :step

  def initialize(step:)
    self.step = step
  end

  # @return [Mixed]
  def call
    return if statement?

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

private

  # @return [Boolean]
  def statement?
    step.contentful_model == "statement"
  end
end
