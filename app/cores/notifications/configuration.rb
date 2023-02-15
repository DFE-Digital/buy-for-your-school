module Notifications
  class Configuration
    def call
      Wisper.subscribe(Notifications::HandleCaseStateChanges.new)
    end
  end
end
