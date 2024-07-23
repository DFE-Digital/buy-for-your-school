module Support
  #
  # Poll the MS Graph copy action until it completes and persist the copied item ID
  # https://learn.microsoft.com/en-us/graph/long-running-actions-overview?tabs=http#initial-action-request
  # Polls every 2 seconds up to 10 times
  #
  class PollCopiedItemJob < ApplicationJob
    queue_as :support
    sidekiq_options retry: 10

    RetryError = Class.new(StandardError)
    RequestError = Class.new(StandardError)

    sidekiq_retry_in do |_count, exception|
      case exception
      when RetryError
        2
      when RequestError
        :kill
      end
    end

    def perform(poll_url, case_id)
      kase = Case.find(case_id)
      return if kase.sharepoint_folder_id.present?

      response = HTTParty.get(poll_url)
      raise RequestError if response.code.to_s[0] != "2"

      body = JSON.parse(response.body)
      raise RetryError if body["status"] != "completed"

      kase.update!(sharepoint_folder_id: body["resourceId"])
    end
  end
end
