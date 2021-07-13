class SaveAnswer
  attr_accessor :answer, :step

  def initialize(answer:)
    self.answer = answer
    self.step = answer.step
  end

  def call(params:)
    result = Result.new(false, answer)

    safe_params = StringSanitiser.new(args: params.to_hash).call
    answer.assign_attributes(safe_params)

    if answer.valid?
      answer.save!
      answer.step.journey.start!
      ToggleAdditionalSteps.new(step: answer.step).call
      result.success = true
    end

    result
  end
end
