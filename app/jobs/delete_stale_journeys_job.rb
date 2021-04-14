class DeleteStaleJourneysJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 1

  def perform
    DeleteStaleJourneys.new.call
  end
end
