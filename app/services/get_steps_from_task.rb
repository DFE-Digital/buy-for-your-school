class GetStepsFromTask
  attr_accessor :task

  def initialize(task:)
    self.task = task
  end

  def call
    return [] unless task.respond_to?(:steps)
    step_ids = []
    task.steps.each do |step|
      step_ids << step.id
    end

    step_ids.map { |entry_id|
      GetEntry.new(entry_id: entry_id).call
    }
  end
end
