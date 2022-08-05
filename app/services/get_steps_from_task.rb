# Fetch and cache unique Contentful steps for the task
#
class GetStepsFromTask
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
        send_rollbar_error(message: "A repeated Contentful entry was found in the same task", step_id: step.id)
        raise RepeatEntryDetected, step.id
      else
        step_ids << step.id
      end
    end

    step_ids.map do |entry_id|
      GetEntry.new(entry_id:, client: @client).call
    end
  end

private

  def send_rollbar_error(message:, step_id:)
    Rollbar.error(
      message,
      contentful_entry_id: step_id,
      contentful_space_id: @client.space,
      contentful_environment: @client.environment,
      contentful_url: @client.api_url,
    )
  end
end
