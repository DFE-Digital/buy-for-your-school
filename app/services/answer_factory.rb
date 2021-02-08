class AnswerFactory
  class UnexpectedQuestionType < StandardError; end

  attr_accessor :step

  def initialize(step:)
    self.step = step
  end

  def call
    case step.contentful_type
    when "radios" then RadioAnswer.new
    when "number" then NumberAnswer.new
    when "currency" then CurrencyAnswer.new
    when "short_text" then ShortTextAnswer.new
    when "long_text" then LongTextAnswer.new
    when "single_date" then SingleDateAnswer.new
    when "checkboxes" then CheckboxAnswers.new
    else raise UnexpectedQuestionType.new "Trying to create answer for unknown question type #{step.contentful_type}"
    end
  end
end
