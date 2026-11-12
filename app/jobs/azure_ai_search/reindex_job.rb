module AzureAiSearch
  class ReindexJob < ApplicationJob
    queue_as :default

    def perform
      ContentfulIndexer.new.sync_all
    end
  end
end
