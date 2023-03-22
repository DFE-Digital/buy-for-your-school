module CaseManagement
  class Configuration
    def call
      Wisper.subscribe(CaseManagement::HandleMessages.new)
    end
  end
end
