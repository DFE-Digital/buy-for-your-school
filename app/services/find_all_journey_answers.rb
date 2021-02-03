class FindAllJourneyAnswers
  class UnexpectedAnswer < StandardError; end

  attr_accessor :journey
  def initialize(journey:)
    self.journey = journey
  end

  def call
    @answers = @journey.steps.that_are_questions.each_with_object({}) { |step, hash|
      next unless step.answer

      answer = case step.answer.class.name
      when "ShortTextAnswer" then ShortTextAnswerPresenter.new(step.answer)
      when "LongTextAnswer" then LongTextAnswerPresenter.new(step.answer)
      when "RadioAnswer" then RadioAnswerPresenter.new(step.answer)
      when "SingleDateAnswer" then SingleDateAnswerPresenter.new(step.answer)
      when "CheckboxAnswers" then CheckboxesAnswerPresenter.new(step.answer)
      else raise UnexpectedAnswer.new("Trying to present an unknown type of answer: #{step.answer.class.name}")
      end

      hash["answer_#{step.contentful_id}"] = answer.response.to_s
    }
  end
end
