module Frameworks
  class SyncFrameworksJob < ApplicationJob
    queue_as :frameworks

    def perform
      Frameworks::SyncFrameworks.new.call
    end
  end
end
