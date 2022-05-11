module Support
  # https://docs.clamav.net/manual/Usage/SignatureManagement.html
  class RefreshVirusDefinitions < ApplicationJob
    queue_as :support

    def perform
      Clamby.update
    end
  end
end
