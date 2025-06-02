module Energy
  class SubmitOnboardingDataJob < ApplicationJob
    queue_as :default

    def perform(id)
      Energy::SubmitOnboardingData.new(id).call
    end
  end
end
