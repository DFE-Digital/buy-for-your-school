module CaseStatistics
  class Configuration
    def call
      Wisper.subscribe(CaseStatistics::HandleCaseStateChanges.new)
    end
  end
end
