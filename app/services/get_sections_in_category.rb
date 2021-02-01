class GetSectionsInCategory
  attr_accessor :category
  def initialize(category:)
    self.category = category
  end

  def call
    category.sections.each_with_object({}) do |section, result|
      result[section.title] = []
      section.steps.map do |step|
        result[section.title] << step.id
      end
    end
  end
end
