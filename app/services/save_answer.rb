class SaveAnswer
  attr_accessor :answer, :step
  def initialize(answer:)
    self.answer = answer
    self.step = answer.step
  end

  def call(answer_params: {}, checkbox_params: {})
    result = Result.new(false, answer)

    case step.contentful_type
    when "checkboxes"
      answer.assign_attributes(checkbox_params)
    else
      answer.assign_attributes(answer_params)
    end

    if answer.valid?
      answer.save
      answer.step.check_to_show_additional_step!
      answer.step.check_to_hide_additional_step!
      result.success = true
    end

    result
  end
end
