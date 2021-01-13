class CreateJourney
  attr_accessor :category

  def initialize(category:)
    self.category = category
  end

  def call
    Journey.create(
      category: category,
      next_entry_id: ENV["CONTENTFUL_PLANNING_START_ENTRY_ID"],
      liquid_template: liquid_template
    )
  end

  private def liquid_template
    FindLiquidTemplate.new(category: category).call
  end
end
