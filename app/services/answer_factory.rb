class AnswerFactory
  attr_accessor :question

  def initialize(question:)
    self.question = question
  end

  def call
    case question.contentful_type
    when "radios" then RadioAnswer.new
    else Answer.new
    end
  end
end
