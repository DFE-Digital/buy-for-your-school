module AzureAiSearch
  class ReindexJob < ApplicationJob
    queue_as :default

    def perform
      AzureAiSearch::SolutionIndexer.new.sync_all
    end
  end
end
