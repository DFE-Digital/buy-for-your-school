module Support
  #
  # Download and process CSV data from GIAS. This touches ~22k records.
  #
  class RefreshSchoolsJob < ApplicationJob
    queue_as :support

    def perform
      SeedSchools.new.call

      track_event("Jobs/RefreshSchoolsJob/Completed")
    end
  end
end
