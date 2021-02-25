class GetAnswersForSteps
  class UnexpectedAnswer < StandardError; end

  include AnswerHelper

  attr_accessor :visible_steps
  def initialize(visible_steps:)
    self.visible_steps = visible_steps
  end

  def call
    visible_steps.each_with_object({}) { |step, hash|
      next unless step.answer

      answer = case step.answer.class.name
      when "ShortTextAnswer" then ShortTextAnswerPresenter.new(step.answer)
      when "LongTextAnswer" then LongTextAnswerPresenter.new(step.answer)
      when "RadioAnswer" then RadioAnswerPresenter.new(step.answer)
      when "SingleDateAnswer" then SingleDateAnswerPresenter.new(step.answer)
      when "CheckboxAnswers" then CheckboxesAnswerPresenter.new(step.answer)
      when "NumberAnswer" then NumberAnswerPresenter.new(step.answer)
      when "CurrencyAnswer" then CurrencyAnswerPresenter.new(step.answer)
      else raise UnexpectedAnswer.new("Trying to present an unknown type of answer: #{step.answer.class.name}")
      end

      if answer.respond_to?(:further_information)
        hash["extended_answer_#{step.contentful_id}"] = if answer.further_information.is_a?(Hash)
          answer.further_information.each_pair.each_with_object([]) do |(key, value), array|
            key_without_prefix = key.gsub("_further_information", "")
            array << {
              "response" => human_readable_option(string: key_without_prefix),
              "further_information" => value
            }
          end
        else
          [
            {
              "response" => answer.response,
              "further_information" => answer.further_information
            }
          ]
        end
      end

      hash["answer_#{step.contentful_id}"] = answer.response.to_s
    }
  end
end
