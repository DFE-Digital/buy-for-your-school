class FeatureFlags
  attr_reader :configuration

  def initialize(configuration)
    @configuration = configuration
  end

  def enabled?(feature_name)
    configuration.fetch(feature_name, false)
  end
end
