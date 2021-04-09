class SaveAnswer
  attr_accessor :answer, :step
  def initialize(answer:)
    self.answer = answer
    self.step = answer.step
  end

  def call(params:)
    result = Result.new(false, answer)

    answer.assign_attributes(params.to_hash)

    if answer.valid?
      answer.save
      answer.step.journey.freshen!
      ToggleAdditionalSteps.new(step: answer.step).call
      result.success = true
    end

    result
  end
end
