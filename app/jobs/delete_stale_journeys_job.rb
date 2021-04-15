class DeleteStaleJourneysJob < ApplicationJob
  queue_as :default

  def perform
    DeleteStaleJourneys.new.call
  end
end
