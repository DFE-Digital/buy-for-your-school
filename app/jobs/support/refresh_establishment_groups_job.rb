module Support
  #
  # Download and process CSV data from GIAS. This touches ~22k records.
  #
  class RefreshEstablishmentGroupsJob < ApplicationJob
    queue_as :support

    def perform
      SeedEstablishmentGroups.new.call

      Rollbar.info "EstablishmentGroup data has been refreshed"
    end
  end
end
