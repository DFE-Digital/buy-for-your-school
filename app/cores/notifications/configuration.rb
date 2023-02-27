module Notifications
  class Configuration
    def call
      Wisper.subscribe(Notifications::HandleCaseStateChanges.new)
      Wisper.subscribe(Notifications::HandleMessages.new)
    end
  end
end
