class GetAnswersForSteps
  class UnexpectedAnswer < StandardError; end

  include AnswerHelper

  attr_accessor :visible_steps
  def initialize(visible_steps:)
    self.visible_steps = visible_steps
  end

  def call
    visible_steps.each_with_object({}) do |step, hash|
      next unless step.answer

      answer =
        case step.answer.class.name
        when "ShortTextAnswer" then ShortTextAnswerPresenter.new(step.answer)
        when "LongTextAnswer" then LongTextAnswerPresenter.new(step.answer)
        when "RadioAnswer" then RadioAnswerPresenter.new(step.answer)
        when "SingleDateAnswer" then SingleDateAnswerPresenter.new(step.answer)
        when "CheckboxAnswers" then CheckboxesAnswerPresenter.new(step.answer)
        when "NumberAnswer" then NumberAnswerPresenter.new(step.answer)
        when "CurrencyAnswer" then CurrencyAnswerPresenter.new(step.answer)
        else raise UnexpectedAnswer, "Trying to present an unknown type of answer: #{step.answer.class.name}"
        end

      safe_answer = StringSanitiser.new(args: answer.to_param).call

      hash["answer_#{step.contentful_id}"] = safe_answer.with_indifferent_access
    end
  end
end
