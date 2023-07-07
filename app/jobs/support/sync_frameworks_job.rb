module Support
  class SyncFrameworksJob < ApplicationJob
    queue_as :support

    def perform
      Support::SyncFrameworks.new.call
    end
  end
end
