module CaseHistory
  class Configuration
    def call
      Wisper.subscribe(CaseHistory::HandleCaseStateChanges.new)
      Wisper.subscribe(CaseHistory::HandleMessages.new)
    end
  end
end
