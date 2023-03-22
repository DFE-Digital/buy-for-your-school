module CaseStatistics
  class Configuration
    def call
      Wisper.subscribe(CaseStatistics::HandleCaseStateChanges.new)
      Wisper.subscribe(CaseStatistics::HandleInteractions.new)
    end
  end
end
