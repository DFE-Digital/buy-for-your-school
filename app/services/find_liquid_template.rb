class FindLiquidTemplate
  attr_accessor :category, :environment

  def initialize(category:, environment: Rails.env)
    self.category = category
    self.environment = environment
  end

  def call
    File.read("lib/specification_templates/#{category}.#{environment}.liquid")
  end
end
