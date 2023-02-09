class CoresConfiguration
  def call
    Wisper.clear

    CaseHistory::Configuration.new.call
    CaseManagement::Configuration.new.call
    CaseStatistics::Configuration.new.call
  end
end

Rails.configuration.to_prepare do
  CoresConfiguration.new.call
end
