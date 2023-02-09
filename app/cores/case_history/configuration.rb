module CaseHistory
  class Configuration
    def call
      Wisper.subscribe(CaseHistory::HandleCaseStateChanges.new)
    end
  end
end
