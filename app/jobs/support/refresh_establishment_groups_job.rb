module Support
  #
  # Download and process CSV data from GIAS. This touches ~22k records.
  #
  class RefreshEstablishmentGroupsJob < ApplicationJob
    queue_as :support

    def perform
      SeedEstablishmentGroups.new.call

      track_event("Jobs/RefreshEstablishmentGroupsJob/Completed")
    end
  end
end
