# Fetch and cache unique Contentful steps for the task
#
class GetStepsFromTask
  include InsightsTrackable

  class RepeatEntryDetected < StandardError; end

  # @param task [Contentful::Entry]
  # @param client [Content::Client]
  #
  def initialize(task:, client: Content::Client.new)
    @task = task
    @client = client
  end

  # @raise [GetStepsFromTask::RepeatEntryDetected]
  #
  # @return [Array<Contentful::Entry>]
  def call
    return [] unless @task.respond_to?(:steps)

    step_ids = []
    @task.steps.each do |step|
      if step_ids.include?(step.id)
        track_error("GetStepsFromTask/RepeatEntryDetected", step_id: step.id)
        raise RepeatEntryDetected, step.id
      else
        step_ids << step.id
      end
    end

    step_ids.map do |entry_id|
      GetEntry.new(entry_id:, client: @client).call
    end
  end
end
