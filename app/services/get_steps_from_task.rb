# Fetch and cache unique Contentful steps for the task
#
class GetStepsFromTask
  class RepeatEntryDetected < StandardError; end

  # @return [Contentful::Entry]
  attr_accessor :task

  # @param task [Contentful::Entry]
  def initialize(task:)
    self.task = task
  end

  # @raise [GetStepsFromTask::RepeatEntryDetected]
  #
  # @return [Array<Contentful::Entry>]
  def call
    return [] unless task.respond_to?(:steps)

    step_ids = []
    task.steps.each do |step|
      if step_ids.include?(step.id)
        send_rollbar_error(message: "A repeated Contentful entry was found in the same task", entry_id: step.id)
        raise RepeatEntryDetected, step.id
      else
        step_ids << step.id
      end
    end

    step_ids.map do |entry_id|
      GetEntry.new(entry_id: entry_id).call
    end
  end

private

  def send_rollbar_error(message:, entry_id:)
    Rollbar.error(
      message,
      contentful_url: ENV["CONTENTFUL_URL"],
      contentful_space_id: ENV["CONTENTFUL_SPACE"],
      contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
      contentful_entry_id: entry_id,
    )
  end
end
