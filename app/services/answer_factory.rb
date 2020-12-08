class AnswerFactory
  attr_accessor :step

  def initialize(step:)
    self.step = step
  end

  def call
    case step.contentful_type
    when "radios" then RadioAnswer.new
    when "short_text" then ShortTextAnswer.new
    when "long_text" then LongTextAnswer.new
    when "single_date" then SingleDateAnswer.new
    end
  end
end
