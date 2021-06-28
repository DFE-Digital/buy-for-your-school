class GetSectionsFromCategory
  attr_accessor :category

  def initialize(category:)
    self.category = category
  end

  def call
    category.sections.map { |section| GetEntry.new(entry_id: section.id).call }
  end
end
