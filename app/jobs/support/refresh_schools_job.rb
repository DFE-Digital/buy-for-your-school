module Support
  #
  # Download and process CSV data from GIAS. This touches ~22k records.
  #
  class RefreshSchoolsJob < ApplicationJob
    queue_as :support

    def perform
      SeedSchools.new.call

      Rollbar.info "GIAS data has been refreshed"
    end
  end
end
